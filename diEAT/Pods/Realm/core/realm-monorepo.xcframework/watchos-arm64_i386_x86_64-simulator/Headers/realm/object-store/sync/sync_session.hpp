///////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#ifndef REALM_OS_SYNC_SESSION_HPP
#define REALM_OS_SYNC_SESSION_HPP

#include <realm/object-store/feature_checks.hpp>
#include <realm/object-store/sync/generic_network_transport.hpp>
#include <realm/sync/config.hpp>
#include <realm/sync/subscriptions.hpp>

#include <realm/util/optional.hpp>
#include <realm/object-store/util/checked_mutex.hpp>
#include <realm/version_id.hpp>

#include <mutex>
#include <unordered_map>
#include <map>

namespace realm {
class DB;
class SyncManager;
class SyncUser;

namespace sync {
class Session;
}

namespace _impl {
class RealmCoordinator;
struct SyncClient;

class SyncProgressNotifier {
public:
    enum class NotifierType { upload, download };
    using ProgressNotifierCallback = void(uint64_t transferred_bytes, uint64_t transferrable_bytes);

    uint64_t register_callback(std::function<ProgressNotifierCallback>, NotifierType direction, bool is_streaming);
    void unregister_callback(uint64_t);

    void set_local_version(uint64_t);
    void update(uint64_t downloaded, uint64_t downloadable, uint64_t uploaded, uint64_t uploadable, uint64_t,
                uint64_t);

private:
    mutable std::mutex m_mutex;

    // How many bytes are uploadable or downloadable.
    struct Progress {
        uint64_t uploadable;
        uint64_t downloadable;
        uint64_t uploaded;
        uint64_t downloaded;
        uint64_t snapshot_version;
    };

    // A PODS encapsulating some information for progress notifier callbacks a binding
    // can register upon this session.
    struct NotifierPackage {
        std::function<ProgressNotifierCallback> notifier;
        util::Optional<uint64_t> captured_transferrable;
        uint64_t snapshot_version;
        bool is_streaming;
        bool is_download;

        std::function<void()> create_invocation(const Progress&, bool&);
    };

    // A counter used as a token to identify progress notifier callbacks registered on this session.
    uint64_t m_progress_notifier_token = 1;
    // Version of the last locally-created transaction that we're expecting to be uploaded.
    uint64_t m_local_transaction_version = 0;

    // Will be `none` until we've received the initial notification from sync.  Note that this
    // happens only once ever during the lifetime of a given `SyncSession`, since these values are
    // expected to semi-monotonically increase, and a lower-bounds estimate is still useful in the
    // event more up-to-date information isn't yet available.  FIXME: If we support transparent
    // client reset in the future, we might need to reset the progress state variables if the Realm
    // is rolled back.
    util::Optional<Progress> m_current_progress;

    std::unordered_map<uint64_t, NotifierPackage> m_packages;
};

} // namespace _impl

class SyncSession : public std::enable_shared_from_this<SyncSession> {
public:
    enum class State {
        Active,
        Dying,
        Inactive,
        WaitingForAccessToken,
    };

    enum class ConnectionState {
        Disconnected,
        Connecting,
        Connected,
    };

    using StateChangeCallback = void(State old_state, State new_state);
    using ConnectionStateChangeCallback = void(ConnectionState old_state, ConnectionState new_state);
    using TransactionCallback = void(VersionID old_version, VersionID new_version);
    using ProgressNotifierCallback = _impl::SyncProgressNotifier::ProgressNotifierCallback;
    using ProgressDirection = _impl::SyncProgressNotifier::NotifierType;

    ~SyncSession();
    State state() const;
    ConnectionState connection_state() const;

    // The on-disk path of the Realm file backing the Realm this `SyncSession` represents.
    std::string const& path() const;

    // Register a callback that will be called when all pending uploads have completed.
    // The callback is run asynchronously, and upon whatever thread the underlying sync client
    // chooses to run it on.
    void wait_for_upload_completion(std::function<void(std::error_code)> callback);

    // Register a callback that will be called when all pending downloads have been completed.
    // Works the same way as `wait_for_upload_completion()`.
    void wait_for_download_completion(std::function<void(std::error_code)> callback);

    // Register a notifier that updates the app regarding progress.
    //
    // If `m_current_progress` is populated when this method is called, the notifier
    // will be called synchronously, to provide the caller with an initial assessment
    // of the state of synchronization. Otherwise, the progress notifier will be
    // registered, and only called once sync has begun providing progress data.
    //
    // If `is_streaming` is true, then the notifier will be called forever, and will
    // always contain the most up-to-date number of downloadable or uploadable bytes.
    // Otherwise, the number of downloaded or uploaded bytes will always be reported
    // relative to the number of downloadable or uploadable bytes at the point in time
    // when the notifier was registered.
    //
    // An integer representing a token is returned. This token can be used to manually
    // unregister the notifier. If the integer is 0, the notifier was not registered.
    //
    // Note that bindings should dispatch the callback onto a separate thread or queue
    // in order to avoid blocking the sync client.
    uint64_t register_progress_notifier(std::function<ProgressNotifierCallback>, ProgressDirection,
                                        bool is_streaming);

    // Unregister a previously registered notifier. If the token is invalid,
    // this method does nothing.
    void unregister_progress_notifier(uint64_t);

    // Registers a callback that is invoked when the the underlying sync session changes
    // its connection state
    uint64_t register_connection_change_callback(std::function<ConnectionStateChangeCallback>);

    // Unregisters a previously registered callback. If the token is invalid,
    // this method does nothing
    void unregister_connection_change_callback(uint64_t);

    // If possible, take the session and do anything necessary to make it `Active`.
    // Specifically:
    // If the sync session is currently `Dying`, ask it to stay alive instead.
    // If the sync session is currently `Inactive`, recreate it.
    // Otherwise, a no-op.
    void revive_if_needed();

    // Perform any actions needed in response to regaining network connectivity.
    void handle_reconnect();

    // Inform the sync session that it should close.
    void close();

    // Inform the sync session that it should log out.
    void log_out();

    // Shut down the synchronization session (sync::Session) and wait for the Realm file to no
    // longer be open on behalf of it.
    void shutdown_and_wait();

    // The access token needs to periodically be refreshed and this is how to
    // let the sync session know to update it's internal copy.
    void update_access_token(std::string signed_token);

    // Request an updated access token from this session's sync user.
    void initiate_access_token_refresh();

    // Update the sync configuration used for this session. The new configuration must have the
    // same user and reference realm url as the old configuration. The session will immediately
    // disconnect (if it was active), and then attempt to connect using the new configuration.
    void update_configuration(SyncConfig new_config);

    // An object representing the user who owns the Realm this `SyncSession` represents.
    std::shared_ptr<SyncUser> user() const
    {
        return m_config.user;
    }

    // A copy of the configuration object describing the Realm this `SyncSession` represents.
    const SyncConfig& config() const
    {
        return m_config;
    }

    // If the `SyncSession` has been configured, the full remote URL of the Realm
    // this `SyncSession` represents.
    util::Optional<std::string> full_realm_url() const
    {
        return m_server_url;
    }

    bool has_flx_subscription_store() const;
    sync::SubscriptionStore* get_flx_subscription_store();

    // Create an external reference to this session. The sync session attempts to remain active
    // as long as an external reference to the session exists.
    std::shared_ptr<SyncSession> external_reference() REQUIRES(!m_external_reference_mutex);

    // Return an existing external reference to this session, if one exists. Otherwise, returns `nullptr`.
    std::shared_ptr<SyncSession> existing_external_reference() REQUIRES(!m_external_reference_mutex);

    // Expose some internal functionality to other parts of the ObjectStore
    // without making it public to everyone
    class Internal {
        friend class _impl::RealmCoordinator;

        static void set_sync_transact_callback(SyncSession& session, std::function<TransactionCallback> callback)
        {
            session.set_sync_transact_callback(std::move(callback));
        }

        static void nonsync_transact_notify(SyncSession& session, VersionID::version_type version)
        {
            session.nonsync_transact_notify(version);
        }

        static std::shared_ptr<DB> get_db(SyncSession& session)
        {
            return session.m_db;
        }
    };

    // Expose some internal functionality to testing code.
    struct OnlyForTesting {
        static void handle_error(SyncSession& session, SyncError error)
        {
            session.handle_error(std::move(error));
        }
        static void nonsync_transact_notify(SyncSession& session, VersionID::version_type version)
        {
            session.nonsync_transact_notify(version);
        }
    };

private:
    using std::enable_shared_from_this<SyncSession>::shared_from_this;
    using CompletionCallbacks = std::map<int64_t, std::pair<ProgressDirection, std::function<void(std::error_code)>>>;

    class ConnectionChangeNotifier {
    public:
        uint64_t add_callback(std::function<ConnectionStateChangeCallback> callback);
        void remove_callback(uint64_t token);
        void invoke_callbacks(ConnectionState old_state, ConnectionState new_state);

    private:
        struct Callback {
            std::function<ConnectionStateChangeCallback> fn;
            uint64_t token;
        };

        std::mutex m_callback_mutex;
        std::vector<Callback> m_callbacks;

        size_t m_callback_index = -1;
        size_t m_callback_count = -1;
        uint64_t m_next_token = 0;
    };

    friend class realm::SyncManager;
    // Called by SyncManager {
    static std::shared_ptr<SyncSession> create(_impl::SyncClient& client, std::shared_ptr<DB> db, SyncConfig config,
                                               SyncManager* sync_manager)
    {
        struct MakeSharedEnabler : public SyncSession {
            MakeSharedEnabler(_impl::SyncClient& client, std::shared_ptr<DB> db, SyncConfig config,
                              SyncManager* sync_manager)
                : SyncSession(client, std::move(db), std::move(config), sync_manager)
            {
            }
        };
        return std::make_shared<MakeSharedEnabler>(client, std::move(db), std::move(config), std::move(sync_manager));
    }
    // }

    std::shared_ptr<SyncManager> sync_manager() const;
    std::shared_ptr<sync::SubscriptionStore> make_flx_subscription_store();

    static std::function<void(util::Optional<app::AppError>)> handle_refresh(std::shared_ptr<SyncSession>);

    SyncSession(_impl::SyncClient&, std::shared_ptr<DB>, SyncConfig, SyncManager* sync_manager);

    void handle_fresh_realm_downloaded(DBRef db, util::Optional<std::string> error_message);
    void handle_error(SyncError);
    void handle_bad_auth(const std::shared_ptr<SyncUser>& user, std::error_code error_code,
                         const std::string& context_message);
    void cancel_pending_waits(std::unique_lock<std::mutex>&, std::error_code);
    enum class ShouldBackup { yes, no };
    void update_error_and_mark_file_for_deletion(SyncError&, ShouldBackup);
    std::string get_recovery_file_path();
    void handle_progress_update(uint64_t, uint64_t, uint64_t, uint64_t, uint64_t, uint64_t);
    void handle_new_flx_sync_query(int64_t version);

    void set_sync_transact_callback(std::function<TransactionCallback>);
    void nonsync_transact_notify(VersionID::version_type);

    void create_sync_session();
    void do_create_sync_session();
    void did_drop_external_reference() REQUIRES(!m_external_reference_mutex);
    void detach_from_sync_manager();
    void close(std::unique_lock<std::mutex>&);

    void become_active(std::unique_lock<std::mutex>&);
    void become_dying(std::unique_lock<std::mutex>&);
    void become_inactive(std::unique_lock<std::mutex>&);
    void become_waiting_for_access_token(std::unique_lock<std::mutex>&);


    void add_completion_callback(const std::unique_lock<std::mutex>&, std::function<void(std::error_code)> callback,
                                 ProgressDirection direction);

    std::function<TransactionCallback> m_sync_transact_callback;

    mutable std::mutex m_state_mutex;

    State m_state = State::Inactive;

    // The underlying state of the connection. Even when sharing connections, the underlying session
    // will always start out as disconnected and then immediately transition to the correct state when calling
    // bind().
    ConnectionState m_connection_state = ConnectionState::Disconnected;
    size_t m_death_count = 0;

    SyncConfig m_config;
    std::shared_ptr<DB> m_db;
    std::shared_ptr<sync::SubscriptionStore> m_flx_subscription_store;
    bool m_force_client_reset = false;
    DBRef m_client_reset_fresh_copy;
    _impl::SyncClient& m_client;
    SyncManager* m_sync_manager = nullptr;

    int64_t m_completion_request_counter = 0;
    CompletionCallbacks m_completion_callbacks;

    // The underlying `Session` object that is owned and managed by this `SyncSession`.
    // The session is first created when the `SyncSession` is moved out of its initial `inactive` state.
    // The session might be destroyed if the `SyncSession` becomes inactive again (for example, if the
    // user owning the session logs out). It might be created anew if the session is revived (if a
    // logged-out user logs back in, the object store sync code will revive their sessions).
    std::unique_ptr<sync::Session> m_session;

    // The fully-resolved URL of this Realm, including the server and the path.
    util::Optional<std::string> m_server_url;

    _impl::SyncProgressNotifier m_progress_notifier;
    ConnectionChangeNotifier m_connection_change_notifier;

    mutable util::CheckedMutex m_external_reference_mutex;
    class ExternalReference;
    std::weak_ptr<ExternalReference> m_external_reference GUARDED_BY(m_external_reference_mutex);
};

} // namespace realm

#endif // REALM_OS_SYNC_SESSION_HPP
