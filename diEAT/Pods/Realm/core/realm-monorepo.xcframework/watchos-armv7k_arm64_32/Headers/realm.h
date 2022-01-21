/*
    FIXME: License, since this header may be distributed independently from
    other headers.
*/

#ifndef REALM_H
#define REALM_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

#if defined(_WIN32) || defined(__CYGWIN__)

#if defined(Realm_EXPORTS)
// Exporting Win32 symbols
#define RLM_EXPORT __declspec(dllexport)
#else
// Importing Win32 symbols. Note: Clients linking statically should define
// RLM_NO_DLLIMPORT.
#if !defined(RLM_NO_DLLIMPORT)
#define RLM_EXPORT __declspec(dllimport)
#else
#define RLM_EXPORT
#endif // RLM_NO_DLLIMPORT
#endif // Realm_EXPORTS

#else
// Not Win32
#define RLM_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
#define RLM_API extern "C" RLM_EXPORT
#define RLM_API_NOEXCEPT noexcept
#else
#define RLM_API RLM_EXPORT
#define RLM_API_NOEXCEPT
#endif // __cplusplus

// Some platforms don't support anonymous unions in structs.
// RLM_NO_ANON_UNIONS allows definining a member name for unions in structs where
// RLM_ANON_UNION_MEMBER(name) is used.
#ifdef RLM_NO_ANON_UNIONS
#define RLM_ANON_UNION_MEMBER(name) name
#else
#define RLM_ANON_UNION_MEMBER(name)
#endif

typedef struct shared_realm realm_t;
typedef struct realm_schema realm_schema_t;
typedef struct realm_scheduler realm_scheduler_t;
typedef struct realm_thread_safe_reference realm_thread_safe_reference_t;
typedef void (*realm_free_userdata_func_t)(void*);
typedef void* (*realm_clone_userdata_func_t)(const void*);

/* Accessor types */
typedef struct realm_object realm_object_t;
typedef struct realm_list realm_list_t;
typedef struct realm_set realm_set_t;
typedef struct realm_dictionary realm_dictionary_t;

/* Query types */
typedef struct realm_query realm_query_t;
typedef struct realm_results realm_results_t;

/* Config types */
typedef struct realm_config realm_config_t;
typedef struct realm_app_config realm_app_config_t;
typedef struct realm_sync_client_config realm_sync_client_config_t;
typedef struct realm_sync_config realm_sync_config_t;
typedef bool (*realm_migration_func_t)(void* userdata, realm_t* old_realm, realm_t* new_realm,
                                       const realm_schema_t* schema);
typedef bool (*realm_data_initialization_func_t)(void* userdata, realm_t* realm);
typedef bool (*realm_should_compact_on_launch_func_t)(void* userdata, uint64_t total_bytes, uint64_t used_bytes);
typedef enum realm_schema_mode {
    RLM_SCHEMA_MODE_AUTOMATIC,
    RLM_SCHEMA_MODE_IMMUTABLE,
    RLM_SCHEMA_MODE_READ_ONLY,
    RLM_SCHEMA_MODE_RESET_FILE,
    RLM_SCHEMA_MODE_ADDITIVE_DISCOVERED,
    RLM_SCHEMA_MODE_ADDITIVE_EXPLICIT,
    RLM_SCHEMA_MODE_MANUAL,
} realm_schema_mode_e;

/* Key types */
typedef uint32_t realm_class_key_t;
typedef int64_t realm_property_key_t;
typedef int64_t realm_object_key_t;
typedef uint64_t realm_version_t;

static const realm_class_key_t RLM_INVALID_CLASS_KEY = ((uint32_t)-1) >> 1;
static const realm_property_key_t RLM_INVALID_PROPERTY_KEY = -1;
static const realm_object_key_t RLM_INVALID_OBJECT_KEY = -1;

/* Value types */

typedef enum realm_value_type {
    RLM_TYPE_NULL,
    RLM_TYPE_INT,
    RLM_TYPE_BOOL,
    RLM_TYPE_STRING,
    RLM_TYPE_BINARY,
    RLM_TYPE_TIMESTAMP,
    RLM_TYPE_FLOAT,
    RLM_TYPE_DOUBLE,
    RLM_TYPE_DECIMAL128,
    RLM_TYPE_OBJECT_ID,
    RLM_TYPE_LINK,
    RLM_TYPE_UUID,
} realm_value_type_e;

typedef enum realm_schema_validation_mode {
    RLM_SCHEMA_VALIDATION_BASIC = 0,
    RLM_SCHEMA_VALIDATION_SYNC = 1,
    RLM_SCHEMA_VALIDATION_REJECT_EMBEDDED_ORPHANS = 2
} realm_schema_validation_mode_e;

typedef struct realm_string {
    const char* data;
    size_t size;
} realm_string_t;

typedef struct realm_binary {
    const uint8_t* data;
    size_t size;
} realm_binary_t;

typedef struct realm_timestamp {
    int64_t seconds;
    int32_t nanoseconds;
} realm_timestamp_t;

typedef struct realm_decimal128 {
    uint64_t w[2];
} realm_decimal128_t;

typedef struct realm_link {
    realm_class_key_t target_table;
    realm_object_key_t target;
} realm_link_t;

typedef struct realm_object_id {
    uint8_t bytes[12];
} realm_object_id_t;

typedef struct realm_uuid {
    uint8_t bytes[16];
} realm_uuid_t;

typedef struct realm_value {
    union {
        int64_t integer;
        bool boolean;
        realm_string_t string;
        realm_binary_t binary;
        realm_timestamp_t timestamp;
        float fnum;
        double dnum;
        realm_decimal128_t decimal128;
        realm_object_id_t object_id;
        realm_uuid_t uuid;

        realm_link_t link;

        char data[16];
    } RLM_ANON_UNION_MEMBER(values);
    realm_value_type_e type;
} realm_value_t;

typedef struct realm_version_id {
    uint64_t version;
    uint64_t index;
} realm_version_id_t;


/* Error types */
typedef struct realm_async_error realm_async_error_t;
typedef enum realm_errno {
    RLM_ERR_NONE = 0,
    RLM_ERR_UNKNOWN,
    RLM_ERR_OTHER_EXCEPTION,
    RLM_ERR_OUT_OF_MEMORY,
    RLM_ERR_NOT_CLONABLE,

    RLM_ERR_NOT_IN_A_TRANSACTION,
    RLM_ERR_WRONG_THREAD,

    RLM_ERR_INVALIDATED_OBJECT,
    RLM_ERR_INVALID_PROPERTY,
    RLM_ERR_MISSING_PROPERTY_VALUE,
    RLM_ERR_PROPERTY_TYPE_MISMATCH,
    RLM_ERR_MISSING_PRIMARY_KEY,
    RLM_ERR_UNEXPECTED_PRIMARY_KEY,
    RLM_ERR_WRONG_PRIMARY_KEY_TYPE,
    RLM_ERR_MODIFY_PRIMARY_KEY,
    RLM_ERR_READ_ONLY_PROPERTY,
    RLM_ERR_PROPERTY_NOT_NULLABLE,
    RLM_ERR_INVALID_ARGUMENT,

    RLM_ERR_LOGIC,
    RLM_ERR_NO_SUCH_TABLE,
    RLM_ERR_NO_SUCH_OBJECT,
    RLM_ERR_CROSS_TABLE_LINK_TARGET,
    RLM_ERR_UNSUPPORTED_FILE_FORMAT_VERSION,
    RLM_ERR_MULTIPLE_SYNC_AGENTS,
    RLM_ERR_ADDRESS_SPACE_EXHAUSTED,
    RLM_ERR_MAXIMUM_FILE_SIZE_EXCEEDED,
    RLM_ERR_OUT_OF_DISK_SPACE,
    RLM_ERR_KEY_NOT_FOUND,
    RLM_ERR_COLUMN_NOT_FOUND,
    RLM_ERR_COLUMN_ALREADY_EXISTS,
    RLM_ERR_KEY_ALREADY_USED,
    RLM_ERR_SERIALIZATION_ERROR,
    RLM_ERR_INVALID_PATH_ERROR,
    RLM_ERR_DUPLICATE_PRIMARY_KEY_VALUE,

    RLM_ERR_INDEX_OUT_OF_BOUNDS,

    RLM_ERR_INVALID_QUERY_STRING,
    RLM_ERR_INVALID_QUERY,

    RLM_ERR_CALLBACK = 1000000, /**< A user-provided callback failed. */
} realm_errno_e;

typedef enum realm_logic_error_kind {
    RLM_LOGIC_ERR_NONE = 0,
    RLM_LOGIC_ERR_STRING_TOO_BIG,
    // ...
} realm_logic_error_kind_e;

typedef struct realm_error {
    realm_errno_e error;
    const char* message;
    union {
        int code;
        realm_logic_error_kind_e logic_error_kind;
    } kind;
} realm_error_t;

/* Schema types */

typedef enum realm_column_attr {
    // Values matching `realm::ColumnAttr`.
    RLM_COLUMN_ATTR_NONE = 0,
    RLM_COLUMN_ATTR_INDEXED = 1,
    RLM_COLUMN_ATTR_UNIQUE = 2,
    RLM_COLUMN_ATTR_RESERVED = 4,
    RLM_COLUMN_ATTR_STRONG_LINKS = 8,
    RLM_COLUMN_ATTR_NULLABLE = 16,
    RLM_COLUMN_ATTR_LIST = 32,
    RLM_COLUMN_ATTR_DICTIONARY = 64,
    RLM_COLUMN_ATTR_COLLECTION = 64 + 32,
} realm_column_attr_e;

typedef enum realm_property_type {
    // Values matching `realm::ColumnType`.
    RLM_PROPERTY_TYPE_INT = 0,
    RLM_PROPERTY_TYPE_BOOL = 1,
    RLM_PROPERTY_TYPE_STRING = 2,
    RLM_PROPERTY_TYPE_BINARY = 4,
    RLM_PROPERTY_TYPE_MIXED = 6,
    RLM_PROPERTY_TYPE_TIMESTAMP = 8,
    RLM_PROPERTY_TYPE_FLOAT = 9,
    RLM_PROPERTY_TYPE_DOUBLE = 10,
    RLM_PROPERTY_TYPE_DECIMAL128 = 11,
    RLM_PROPERTY_TYPE_OBJECT = 12,
    RLM_PROPERTY_TYPE_LINKING_OBJECTS = 14,
    RLM_PROPERTY_TYPE_OBJECT_ID = 15,
    RLM_PROPERTY_TYPE_UUID = 17,
} realm_property_type_e;

typedef enum realm_collection_type {
    RLM_COLLECTION_TYPE_NONE = 0,
    RLM_COLLECTION_TYPE_LIST = 1,
    RLM_COLLECTION_TYPE_SET = 2,
    RLM_COLLECTION_TYPE_DICTIONARY = 4,
} realm_collection_type_e;

typedef struct realm_property_info {
    const char* name;
    const char* public_name;
    realm_property_type_e type;
    realm_collection_type_e collection_type;

    const char* link_target;
    const char* link_origin_property_name;
    realm_property_key_t key;
    int flags;
} realm_property_info_t;

typedef struct realm_class_info {
    const char* name;
    const char* primary_key;
    size_t num_properties;
    size_t num_computed_properties;
    realm_class_key_t key;
    int flags;
} realm_class_info_t;

typedef enum realm_class_flags {
    RLM_CLASS_NORMAL = 0,
    RLM_CLASS_EMBEDDED = 1,
} realm_class_flags_e;

typedef enum realm_property_flags {
    RLM_PROPERTY_NORMAL = 0,
    RLM_PROPERTY_NULLABLE = 1,
    RLM_PROPERTY_PRIMARY_KEY = 2,
    RLM_PROPERTY_INDEXED = 4,
} realm_property_flags_e;


/* Notification types */
typedef struct realm_notification_token realm_notification_token_t;
typedef struct realm_object_changes realm_object_changes_t;
typedef struct realm_collection_changes realm_collection_changes_t;
typedef void (*realm_on_object_change_func_t)(void* userdata, const realm_object_changes_t*);
typedef void (*realm_on_collection_change_func_t)(void* userdata, const realm_collection_changes_t*);
typedef void (*realm_callback_error_func_t)(void* userdata, const realm_async_error_t*);
typedef void (*realm_on_realm_change_func_t)(void* userdata);

/**
 * Callback for realm schema changed notifications.
 *
 * @param new_schema The new schema. This object is released after the callback returns.
 *                   Preserve it with realm_clone() if you wish to keep it around for longer.
 */
typedef void (*realm_on_schema_change_func_t)(void* userdata, const realm_schema_t* new_schema);

/* Scheduler types */
typedef void (*realm_scheduler_notify_func_t)(void* userdata);
typedef bool (*realm_scheduler_is_on_thread_func_t)(void* userdata);
typedef bool (*realm_scheduler_is_same_as_func_t)(const void* userdata1, const void* userdata2);
typedef bool (*realm_scheduler_can_deliver_notifications_func_t)(void* userdata);
typedef void (*realm_scheduler_set_notify_callback_func_t)(void* userdata, void* callback_userdata,
                                                           realm_free_userdata_func_t, realm_scheduler_notify_func_t);
typedef realm_scheduler_t* (*realm_scheduler_default_factory_func_t)(void* userdata);

/**
 * Get the VersionID of the current transaction.
 *
 * @param out_found True if version information is available. This requires an available Read or Write transaction.
 * @param out_version The version of the current transaction. If `out_found` returns False, this returns (0,0).
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_version_id(const realm_t*, bool* out_found, realm_version_id_t* out_version);

/**
 * Get a string representing the version number of the Realm library.
 *
 * @return A null-terminated string.
 */
RLM_API const char* realm_get_library_version(void);

/**
 * Get individual components of the version number of the Realm library.
 *
 * @param out_major The major version number (X.0.0).
 * @param out_minor The minor version number (0.X.0).
 * @param out_patch The patch version number (0.0.X).
 * @param out_extra The extra version string (0.0.0-X).
 */
RLM_API void realm_get_library_version_numbers(int* out_major, int* out_minor, int* out_patch,
                                               const char** out_extra);

/**
 * Get the last error that happened on this thread.
 *
 * Errors are thread-local. Getting the error must happen on the same thread as
 * the call that caused the error to occur. The error is specific to the current
 * thread, and not the Realm instance for which the error occurred.
 *
 * Note: The error message in @a err will only be safe to use until the next API
 *       call is made on the current thread.
 *
 * Note: The error is not cleared by subsequent successful calls to this
 *       function, but it will be overwritten by subsequent failing calls to
 *       other library functions.
 *
 * Note: Calling this function does not clear the current last error.
 *
 * This function does not allocate any memory.
 *
 * @param err A pointer to a `realm_error_t` struct that will be populated with
 *            information about the last error, if there is one. May be NULL.
 * @return True if an error occurred.
 */
RLM_API bool realm_get_last_error(realm_error_t* err);

/**
 * Get information about an async error, potentially coming from another thread.
 *
 * This function does not allocate any memory.
 *
 * @param err A pointer to a `realm_error_t` struct that will be populated with
 *            information about the error. May not be NULL.
 * @see realm_get_last_error()
 */
RLM_API void realm_get_async_error(const realm_async_error_t* err, realm_error_t* out_err);

/**
 * Convert the last error to `realm_async_error_t`, which can safely be passed
 * between threads.
 *
 * Note: This function does not clear the last error.
 *
 * @return A non-null pointer if there was an error on this thread.
 * @see realm_get_last_error()
 * @see realm_get_async_error()
 * @see realm_clear_last_error()
 */
RLM_API realm_async_error_t* realm_get_last_error_as_async_error(void);

#if defined(__cplusplus)
/**
 * Invoke a function that may throw an exception, and report that exception as
 * part of the C API error handling mechanism.
 *
 * This is used to test translation of exceptions to error codes.
 *
 * @return True if no exception was thrown.
 */
RLM_EXPORT bool realm_wrap_exceptions(void (*)()) noexcept;
#endif // __cplusplus

/**
 * Clear the last error on the calling thread.
 *
 * Use this if the system has recovered from an error, e.g. by closing the
 * offending Realm and reopening it, freeing up resources, or similar.
 *
 * @return True if an error was cleared.
 */
RLM_API bool realm_clear_last_error(void);

/**
 * Free memory allocated by the module this library was linked into.
 *
 * This is needed for raw memory buffers such as string copies or arrays
 * returned from a library function. Realm C Wrapper objects on the other hand
 * should always be freed with realm_release() only.
 */
RLM_API void realm_free(void* buffer);

/**
 * Free any Realm C Wrapper object.
 *
 * Note: Any pointer returned from a library function is owned by the caller.
 *       The caller is responsible for calling `realm_release()`. The only
 *       exception from this is C++ bridge functions that return `void*`, with
 *       the prefix `_realm`.
 *
 * Note: C++ destructors are typically `noexcept`, so it is likely that an
 *       exception will crash the process.
 *
 * @param ptr A pointer to a Realm C Wrapper object. May be NULL.
 */
RLM_API void realm_release(void* ptr);

/**
 * Clone a Realm C Wrapper object.
 *
 * If the object is not clonable, this function fails with RLM_ERR_NOT_CLONABLE.
 *
 * @return A pointer to an object of the same type as the input, or NULL if
 *         cloning failed.
 */
RLM_API void* realm_clone(const void*);

/**
 * Return true if two API objects refer to the same underlying data. Objects
 * with different types are never equal.
 *
 * Note: This function cannot be used with types that have value semantics, only
 *       opaque types that have object semantics.
 *
 *    - `realm_t` objects are identical if they represent the same instance (not
 *      just if they represent the same file).
 *    - `realm_schema_t` objects are equal if the represented schemas are equal.
 *    - `realm_config_t` objects are equal if the configurations are equal.
 *    - `realm_object_t` objects are identical if they belong to the same realm
 *      and class, and have the same object key.
 *    - `realm_list_t` and other collection objects are identical if they come
 *      from the same object and property.
 *    - `realm_query_t` objects are never equal.
 *    - `realm_scheduler_t` objects are equal if they represent the same
 *      scheduler.
 *    - Query descriptor objects are equal if they represent equivalent
 *      descriptors.
 *    - `realm_async_error_t` objects are equal if they represent the same
 *      exception instance.
 *
 * This function cannot fail.
 */
RLM_API bool realm_equals(const void*, const void*);

/**
 * True if a Realm C Wrapper object is "frozen" (immutable).
 *
 * Objects, collections, and results can be frozen. For all other types, this
 * function always returns false.
 */
RLM_API bool realm_is_frozen(const void*);

/**
 * Get a thread-safe reference representing the same underlying object as some
 * API object.
 *
 * The thread safe reference can be passed to a different thread and resolved
 * against a different `realm_t` instance, which succeeds if the underlying
 * object still exists.
 *
 * The following types can produce thread safe references:
 *
 * - `realm_object_t`
 * - `realm_results_t`
 * - `realm_list_t`
 * - `realm_t`
 *
 * This does not assume ownership of the object, except for `realm_t`, where the
 * instance is transferred by value, and must be transferred back to the current
 * thread to be used. Note that the `realm_thread_safe_reference_t` object must
 * still be destroyed after having been converted into a `realm_t` object.
 *
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_thread_safe_reference_t* realm_create_thread_safe_reference(const void*);

/**
 * Allocate a new configuration with default options.
 */
RLM_API realm_config_t* realm_config_new(void);

/**
 * Get the path of the realm being opened.
 *
 * This function cannot fail.
 */
RLM_API const char* realm_config_get_path(const realm_config_t*);

/**
 * Set the path of the realm being opened.
 *
 * This function aborts when out of memory, but otherwise cannot fail.
 */
RLM_API void realm_config_set_path(realm_config_t*, const char* path);

/**
 * Get the encryption key for the realm.
 *
 * The output buffer must be at least 64 bytes.
 *
 * @returns The length of the encryption key (0 or 64)
 */
RLM_API size_t realm_config_get_encryption_key(const realm_config_t*, uint8_t* out_key);

/**
 * Set the encryption key for the realm.
 *
 * The key must be either 64 bytes long or have length zero (in which case
 * encryption is disabled).
 *
 * This function may fail if the encryption key has the wrong length.
 */
RLM_API bool realm_config_set_encryption_key(realm_config_t*, const uint8_t* key, size_t key_size);

/**
 * Get the schema for this realm.
 *
 * Note: The caller obtains ownership of the returned value, and must manually
 *       free it by calling `realm_release()`.
 *
 * @return A schema object, or NULL if the schema is not set (empty).
 */
RLM_API realm_schema_t* realm_config_get_schema(const realm_config_t*);

/**
 * Set the schema object for this realm.
 *
 * This does not take ownership of the schema object, and it should be released
 * afterwards.
 *
 * This function aborts when out of memory, but otherwise cannot fail.
 *
 * @param schema The schema object. May be NULL, which means an empty schema.
 */
RLM_API void realm_config_set_schema(realm_config_t*, const realm_schema_t* schema);

/**
 * Get the schema version of the schema.
 *
 * This function cannot fail.
 */
RLM_API uint64_t realm_config_get_schema_version(const realm_config_t*);

/**
 * Set the schema version of the schema.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_schema_version(realm_config_t*, uint64_t version);

/**
 * Get the schema mode.
 *
 * This function cannot fail.
 */
RLM_API realm_schema_mode_e realm_config_get_schema_mode(const realm_config_t*);

/**
 * Set the schema mode.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_schema_mode(realm_config_t*, realm_schema_mode_e);

/**
 * Set the migration callback.
 *
 * The migration function is called during a migration for schema modes
 * `RLM_SCHEMA_MODE_AUTOMATIC` and `RLM_SCHEMA_MODE_MANUAL`. The callback is
 * invoked with a realm instance before the migration and the realm instance
 * that is currently performing the migration.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_migration_function(realm_config_t*, realm_migration_func_t, void* userdata);

/**
 * Set the data initialization function.
 *
 * The callback is invoked the first time the schema is created, such that the
 * user can perform one-time initialization of the data in the realm.
 *
 * The realm instance passed to the callback is in a write transaction.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_data_initialization_function(realm_config_t*, realm_data_initialization_func_t,
                                                           void* userdata);

/**
 * Set the should-compact-on-launch callback.
 *
 * The callback is invoked the first time a realm file is opened in this process
 * to decide whether the realm file should be compacted.
 *
 * Note: If another process has the realm file open, it will not be compacted.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_should_compact_on_launch_function(realm_config_t*,
                                                                realm_should_compact_on_launch_func_t,
                                                                void* userdata);

/**
 * True if file format upgrades on open are disabled.
 *
 * This function cannot fail.
 */
RLM_API bool realm_config_get_disable_format_upgrade(const realm_config_t*);

/**
 * Disable file format upgrade on open (default: false).
 *
 * If a migration is needed to open the realm file with the provided schema, an
 * error is thrown rather than automatically performing the migration.
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_disable_format_upgrade(realm_config_t*, bool);

/**
 * True if automatic change notifications should be generated.
 *
 * This function cannot fail.
 */
RLM_API bool realm_config_get_automatic_change_notifications(const realm_config_t*);

/**
 * Automatically generated change notifications (default: true).
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_automatic_change_notifications(realm_config_t*, bool);

/**
 * The scheduler which this realm should be bound to (default: NULL).
 *
 * If NULL, the realm will be bound to the default scheduler for the current thread.
 *
 * This function aborts when out of memory, but otherwise cannot fail.
 */
RLM_API void realm_config_set_scheduler(realm_config_t*, const realm_scheduler_t*);

/**
 * Sync configuration for this realm (default: NULL).
 *
 * This function aborts when out of memory, but otherwise cannot fail.
 */
RLM_API void realm_config_set_sync_config(realm_config_t*, realm_sync_config_t*);

/**
 * Get whether the realm file should be forcibly initialized as a synchronized.
 *
 * This function cannot fail.
 */
RLM_API bool realm_config_get_force_sync_history(const realm_config_t*);

/**
 * Force the realm file to be initialized as a synchronized realm, even if no
 * sync config is provided (default: false).
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_force_sync_history(realm_config_t*, bool);

/**
 * Set the audit interface for the realm (unimplemented).
 */
RLM_API bool realm_config_set_audit_factory(realm_config_t*, void*);

/**
 * Get maximum number of active versions in the realm file allowed before an
 * exception is thrown.
 *
 * This function cannot fail.
 */
RLM_API uint64_t realm_config_get_max_number_of_active_versions(const realm_config_t*);

/**
 * Set maximum number of active versions in the realm file allowed before an
 * exception is thrown (default: UINT64_MAX).
 *
 * This function cannot fail.
 */
RLM_API void realm_config_set_max_number_of_active_versions(realm_config_t*, uint64_t);

/**
 * Create a custom scheduler object from callback functions.
 *
 * @param userdata Pointer passed to all callbacks.
 * @param notify Function to trigger a call to the registered callback on the
 *               scheduler's event loop. This function must be thread-safe, or
 *               NULL, in which case the scheduler is considered unable to
 *               deliver notifications.
 * @param is_on_thread Function to return true if called from the same thread as
 *                     the scheduler. This function must be thread-safe.
 * @param can_deliver_notifications Function to return true if the scheduler can
 *                                  support `notify()`. This function does not
 *                                  need to be thread-safe.
 * @param set_notify_callback Function to accept a callback that will be invoked
 *                            by `notify()` on the scheduler's event loop. This
 *                            function does not need to be thread-safe.
 */
RLM_API realm_scheduler_t*
realm_scheduler_new(void* userdata, realm_free_userdata_func_t, realm_scheduler_notify_func_t notify,
                    realm_scheduler_is_on_thread_func_t is_on_thread, realm_scheduler_is_same_as_func_t is_same_as,
                    realm_scheduler_can_deliver_notifications_func_t can_deliver_notifications,
                    realm_scheduler_set_notify_callback_func_t set_notify_callback);

/**
 * Create an instance of the default scheduler for the current platform,
 * normally confined to the calling thread.
 */
RLM_API realm_scheduler_t* realm_scheduler_make_default(void);

/**
 * Get the scheduler used by frozen realms. This scheduler does not support
 * notifications, and does not perform any thread checking.
 *
 * This function is thread-safe, and cannot fail.
 */
RLM_API const realm_scheduler_t* realm_scheduler_get_frozen(void);

/**
 * Returns true if there is a default scheduler implementation for the current
 * platform, or one has been set with `realm_scheduler_set_default_factory()`.
 *
 * If there is no default factory, and no scheduler is provided in the config,
 * `realm_open()` will fail. Note that `realm_scheduler_get_frozen()` always
 * returns a valid scheduler.
 *
 * This function is thread-safe, and cannot fail.
 */
RLM_API bool realm_scheduler_has_default_factory(void);

/**
 * For platforms with no default scheduler implementation, register a factory
 * function which can produce custom schedulers. If there is a platform-specific
 * scheduler, this function will fail. If a custom scheduler is desired for
 * platforms that already have a default scheduler implementation, the caller
 * must call `realm_open()` with a config that indicates the desired scheduler.
 *
 * The provided callback may produce a scheduler by calling
 * `realm_scheduler_new()`.
 *
 * This function is thread-safe, but should generally only be called once.
 */
RLM_API bool realm_scheduler_set_default_factory(void* userdata, realm_free_userdata_func_t,
                                                 realm_scheduler_default_factory_func_t);

/**
 * Trigger a call to the registered notifier callback on the scheduler's event loop.
 *
 * This function is thread-safe.
 */
RLM_API void realm_scheduler_notify(realm_scheduler_t*);

/**
 * Returns true if the caller is currently running on the scheduler's thread.
 *
 * This function is thread-safe.
 */
RLM_API bool realm_scheduler_is_on_thread(const realm_scheduler_t*);

/**
 * Returns true if the scheduler is able to deliver notifications.
 *
 * A false return value may indicate that notifications are not applicable for
 * the scheduler, not implementable, or a temporary inability to deliver
 * notifications.
 *
 * This function is not thread-safe.
 */
RLM_API bool realm_scheduler_can_deliver_notifications(const realm_scheduler_t*);

/**
 * Set the callback that will be invoked by `realm_scheduler_notify()`.
 *
 * This function is not thread-safe.
 */
RLM_API bool realm_scheduler_set_notify_callback(realm_scheduler_t*, void* userdata, realm_free_userdata_func_t,
                                                 realm_scheduler_notify_func_t);


/**
 * Open a Realm file.
 *
 * @param config Realm configuration. If the Realm is already opened on another
 *               thread, validate that the given configuration is compatible
 *               with the existing one.
 * @return If successful, the Realm object. Otherwise, NULL.
 */
RLM_API realm_t* realm_open(const realm_config_t* config);

/**
 * Create a `realm_t` object from a thread-safe reference to the same realm.
 *
 * @param tsr Thread-safe reference object created by calling
 *            `realm_get_thread_safe_reference()` with a `realm_t` instance.
 * @param scheduler The scheduler to use for the new `realm_t` instance. May be
 *                  NULL, in which case the default scheduler for the current
 *                  thread is used.
 * @return A non-null pointer if no error occurred.
 */
RLM_API realm_t* realm_from_thread_safe_reference(realm_thread_safe_reference_t* tsr, realm_scheduler_t* scheduler);

/**
 * Create a `realm_t*` from a `std::shared_ptr<Realm>*`.
 *
 * This is intended as a migration path for users of the C++ Object Store API.
 *
 * Call `realm_release()` on the returned `realm_t*` to decrement the refcount
 * on the inner `std::shared_ptr<Realm>`.
 *
 * @param pshared_ptr A pointer to an instance of `std::shared_ptr<Realm>`.
 * @param n Must be equal to `sizeof(std::shared_ptr<Realm>)`.
 * @return A `realm_t*` representing the same Realm object as the passed
 *         `std::shared_ptr<Realm>`.
 */
RLM_API realm_t* _realm_from_native_ptr(const void* pshared_ptr, size_t n);

/**
 * Get a `std::shared_ptr<Realm>` from a `realm_t*`.
 *
 * This is intended as a migration path for users of the C++ Object Store API.
 *
 * @param pshared_ptr A pointer to an instance of `std::shared_ptr<Realm>`.
 * @param n Must be equal to `sizeof(std::shared_ptr<Realm>)`.
 */
RLM_API void _realm_get_native_ptr(const realm_t*, void* pshared_ptr, size_t n);

/**
 * Forcibly close a Realm file.
 *
 * Note that this invalidates all Realm instances for the same path.
 *
 * The Realm will be automatically closed when the last reference is released,
 * including references to objects within the Realm.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_close(realm_t*);

/**
 * True if the Realm file is closed.
 *
 * This function cannot fail.
 */
RLM_API bool realm_is_closed(realm_t*);

/**
 * Begin a read transaction for the Realm file.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_begin_read(realm_t*);

/**
 * Begin a write transaction for the Realm file.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_begin_write(realm_t*);

/**
 * Return true if the realm is in a write transaction.
 *
 * This function cannot fail.
 */
RLM_API bool realm_is_writable(const realm_t*);

/**
 * Commit a write transaction.
 *
 * @return True if the commit succeeded and no exceptions were thrown.
 */
RLM_API bool realm_commit(realm_t*);

/**
 * Roll back a write transaction.
 *
 * @return True if the rollback succeeded and no exceptions were thrown.
 */
RLM_API bool realm_rollback(realm_t*);

/**
 * Add a callback that will be invoked every time the view of this file is updated.
 *
 * This callback is guaranteed to be invoked before any object or collection change
 * notifications for this realm are delivered.
 *
 * @return a registration token used to remove the callback.
 */
RLM_API uint64_t realm_add_realm_changed_callback(realm_t*, realm_on_realm_change_func_t, void* userdata,
                                                  realm_free_userdata_func_t);

/**
 * Remove a realm changed callback that was previously registered with the token.
 */
RLM_API void realm_remove_realm_changed_callback(realm_t*, uint64_t token);

/**
 * Refresh the view of the realm file.
 *
 * If another process or thread has made changes to the realm file, this causes
 * those changes to become visible in this realm instance.
 *
 * This calls `advance_read()` at the Core layer.
 *
 * @return True if the realm was successfully refreshed and no exceptions were
 *         thrown.
 */
RLM_API bool realm_refresh(realm_t*);

/**
 * Produce a frozen view of this realm.
 *
 * @return A non-NULL realm instance representing the frozen state.
 */
RLM_API realm_t* realm_freeze(const realm_t*);

/**
 * Vacuum the free space from the realm file, reducing its file size.
 *
 * @return True if compaction was successful and no exceptions were thrown.
 */
RLM_API bool realm_compact(realm_t*, bool* did_compact);

/**
 * Create a new schema from classes and their properties.
 *
 * Note: This function does not validate the schema.
 *
 * Note: `realm_class_key_t` and `realm_property_key_t` values inside
 *       `realm_class_info_t` and `realm_property_info_t` are unused when
 *       defining the schema. Call `realm_get_schema()` to obtain the values for
 *       these fields in an open realm.
 *
 * @return True if allocation of the schema structure succeeded.
 */
RLM_API realm_schema_t* realm_schema_new(const realm_class_info_t* classes, size_t num_classes,
                                         const realm_property_info_t** class_properties);

/**
 * Get the schema for this realm.
 *
 * Note: The returned value is allocated by this function, so `realm_release()`
 *       must be called on it.
 */
RLM_API realm_schema_t* realm_get_schema(const realm_t*);

/**
 * Update the schema of an open realm.
 *
 * This is equivalent to calling `realm_update_schema_advanced(realm, schema, 0,
 * NULL, NULL, NULL, NULL, false)`.
 */
RLM_API bool realm_update_schema(realm_t* realm, const realm_schema_t* schema);

/**
 * Update the schema of an open realm, with options to customize certain steps
 * of the process.
 *
 * @param realm The realm for which the schema should be updated.
 * @param schema The new schema for the realm. If the schema is the same the
 *               existing schema, this function does nothing.
 * @param version The version of the new schema.
 * @param migration_func Callback to perform the migration. Has no effect if the
 *                       Realm is opened with `RLM_SCHEMA_MODE_ADDITIVE`.
 * @param migration_func_userdata Userdata pointer to pass to `migration_func`.
 * @param data_init_func Callback to perform initialization of the data in the
 *                       Realm if it is opened for the first time (i.e., it has
 *                       no previous schema version).
 * @param data_init_func_userdata Userdata pointer to pass to `data_init_func`.
 * @param is_in_transaction Pass true if the realm is already in a write
 *                          transaction. Otherwise, if the migration requires a
 *                          write transaction, this function will perform the
 *                          migration in its own write transaction.
 */
RLM_API bool realm_update_schema_advanced(realm_t* realm, const realm_schema_t* schema, uint64_t version,
                                          realm_migration_func_t migration_func, void* migration_func_userdata,
                                          realm_data_initialization_func_t data_init_func,
                                          void* data_init_func_userdata, bool is_in_transaction);

/**
 * Get the `realm::Schema*` pointer for this realm.
 *
 * This is intended as a migration path for users of the C++ Object Store API.
 *
 * The returned value is owned by the `realm_t` instance, and must not be freed.
 */
RLM_API const void* _realm_get_schema_native(const realm_t*);

/**
 * Add a callback that will be invoked every time the schema of this realm is changed.
 *
 * @return a registration token used to remove the callback.
 */
RLM_API uint64_t realm_add_schema_changed_callback(realm_t*, realm_on_schema_change_func_t, void* userdata,
                                                   realm_free_userdata_func_t);

/**
 * Remove a schema changed callback that was previously registered with the token.
 */
RLM_API void realm_remove_schema_changed_callback(realm_t*, uint64_t token);

/**
 * Validate the schema.
 *
 *  @param validation_mode A bitwise combination of values from the
 *                         enum realm_schema_validation_mode.
 *
 * @return True if the schema passed validation. If validation failed,
 *         `realm_get_last_error()` will produce an error describing the
 *         validation failure.
 */
RLM_API bool realm_schema_validate(const realm_schema_t*, uint64_t validation_mode);

/**
 * Return the number of classes in the Realm's schema.
 *
 * This cannot fail.
 */
RLM_API size_t realm_get_num_classes(const realm_t*);

/**
 * Get the table keys for classes in the schema.
 *
 * @param out_keys An array that will contain the keys of each class in the
 *                 schema. May be NULL, in which case `out_n` can be used to
 *                 determine the number of classes in the schema.
 * @param max The maximum number of keys to write to `out_keys`.
 * @param out_n The actual number of classes. May be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_class_keys(const realm_t*, realm_class_key_t* out_keys, size_t max, size_t* out_n);

/**
 * Find a by the name of @a name.
 *
 * @param name The name of the class.
 * @param out_found Set to true if the class was found and no error occurred.
 *                  Otherwise, false. May not be NULL.
 * @param out_class_info A pointer to a `realm_class_info_t` that will be
 *                       populated with information about the class. May be
 *                       NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_find_class(const realm_t*, const char* name, bool* out_found, realm_class_info_t* out_class_info);

/**
 * Get the class with @a key from the schema.
 *
 * Passing an invalid @a key for this schema is considered an error.
 *
 * @param key The key of the class, as discovered by `realm_get_class_keys()`.
 * @param out_class_info A pointer to a `realm_class_info_t` that will be
 *                       populated with the information of the class. May be
 *                       NULL, though that's kind of pointless.
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_class(const realm_t*, realm_class_key_t key, realm_class_info_t* out_class_info);

/**
 * Get the list of properties for the class with this @a key.
 *
 * @param out_properties A pointer to an array of `realm_property_info_t`, which
 *                       will be populated with the information about the
 *                       properties. To see all properties, the length of the
 *                       array should be at least the number of properties in
 *                       the class, as reported in the sum of persisted and
 *                       computed properties for the class. May be NULL, in
 *                       which case this function can be used to discover the
 *                       number of properties in the class.
 * @param max The maximum number of entries to write to `out_properties`.
 * @param out_n The actual number of properties written to `out_properties`.
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_class_properties(const realm_t*, realm_class_key_t key, realm_property_info_t* out_properties,
                                        size_t max, size_t* out_n);

/**
 * Get the property keys for the class with this @a key.
 *
 * @param key The class key.
 * @param out_col_keys An array of property keys. May be NULL, in which case
 *                     this function can be used to discover the number of
 *                     properties for this class.
 * @param max The maximum number of keys to write to `out_col_keys`. Ignored if
 *            `out_col_keys == NULL`.
 * @param out_n The actual number of properties written to `out_col_keys` (if
 *              non-NULL), or number of properties in the class.
 **/
RLM_API bool realm_get_property_keys(const realm_t*, realm_class_key_t key, realm_property_key_t* out_col_keys,
                                     size_t max, size_t* out_n);


/**
 * Find a property by its column key.
 *
 * It is an error to pass a property @a key that is not present in this class.
 *
 * @param class_key The key of the class.
 * @param key The column key for the property.
 * @param out_property_info A pointer to a `realm_property_info_t` that will be
 *                          populated with information about the property.
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_property(const realm_t*, realm_class_key_t class_key, realm_property_key_t key,
                                realm_property_info_t* out_property_info);

/**
 * Find a property by the internal (non-public) name of @a name.
 *
 * @param class_key The table key for the class.
 * @param name The name of the property.
 * @param out_found Will be set to true if the property was found. May not be
 *                  NULL.
 * @param out_property_info A pointer to a `realm_property_info_t` that will be
 *                          populated with information about the property. May
 *                          be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_find_property(const realm_t*, realm_class_key_t class_key, const char* name, bool* out_found,
                                 realm_property_info_t* out_property_info);

/**
 * Find a property with the public name of @a name.
 *
 * @param class_key The table key for the class.
 * @param public_name The public name of the property.
 * @param out_found Will be set to true if the property was found. May not be
 *                  NULL.
 * @param out_property_info A pointer to a `realm_property_info_t` that will be
 *                          populated with information about the property. May
 *                          be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_find_property_by_public_name(const realm_t*, realm_class_key_t class_key, const char* public_name,
                                                bool* out_found, realm_property_info_t* out_property_info);

/**
 * Find the primary key property for a class, if it has one.
 *
 * @param class_key The table key for this class.
 * @param out_found Will be set to true if the property was found. May not be
 *                  NULL.
 * @param out_property_info A property to a `realm_property_info_t` that will be
 *                          populated with information about the property, if it
 *                          was found. May be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_find_primary_key_property(const realm_t*, realm_class_key_t class_key, bool* out_found,
                                             realm_property_info_t* out_property_info);

/**
 * Get the number of objects in a table (class).
 *
 * @param out_count A pointer to a `size_t` that will contain the number of
 *                  objects, if successful.
 * @return True if the table key was valid for this realm.
 */
RLM_API bool realm_get_num_objects(const realm_t*, realm_class_key_t, size_t* out_count);

/**
 * Get the number of versions found in the Realm file.
 *
 * @param out_versions_count A pointer to a `size_t` that will contain the number of
 *                           versions, if successful.
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_num_versions(const realm_t*, uint64_t* out_versions_count);

/**
 * Get an object with a particular object key.
 *
 * @param class_key The class key.
 * @param obj_key The key to the object. Passing a non-existent key is
 *                considered an error.
 * @return A non-NULL pointer if no exception occurred.
 */
RLM_API realm_object_t* realm_get_object(const realm_t*, realm_class_key_t class_key, realm_object_key_t obj_key);

/**
 * Find an object with a particular primary key value.
 *
 * @param out_found A pointer to a boolean that will be set to true or false if
 *                  no error occurred.
 * @return A non-NULL pointer if the object was found and no exception occurred.
 */
RLM_API realm_object_t* realm_object_find_with_primary_key(const realm_t*, realm_class_key_t, realm_value_t pk,
                                                           bool* out_found);

/**
 * Find all objects in class.
 *
 * Note: This is faster than running a query matching all objects (such as
 *       "TRUEPREDICATE").
 *
 * @return A non-NULL pointer if no exception was thrown.
 */
RLM_API realm_results_t* realm_object_find_all(const realm_t*, realm_class_key_t);

/**
 * Create an object in a class without a primary key.
 *
 * @return A non-NULL pointer if the object was created successfully.
 */
RLM_API realm_object_t* realm_object_create(realm_t*, realm_class_key_t);

/**
 * Create an object in a class with a primary key. Will not succeed if an
 * object with the given primary key value already exists.
 *
 * @return A non-NULL pointer if the object was created successfully.
 */
RLM_API realm_object_t* realm_object_create_with_primary_key(realm_t*, realm_class_key_t, realm_value_t pk);

/**
 * Create an object in a class with a primary key. If an object with the given
 * primary key value already exists, that object will be returned.
 *
 * @return A non-NULL pointer if the object was found/created successfully.
 */
RLM_API realm_object_t* realm_object_get_or_create_with_primary_key(realm_t*, realm_class_key_t, realm_value_t pk,
                                                                    bool* did_create);

/**
 * Delete a realm object.
 *
 * Note: This does not call `realm_release()` on the `realm_object_t` instance.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_object_delete(realm_object_t*);

/**
 * Resolve the Realm object in the provided Realm.
 *
 * This is equivalent to producing a thread-safe reference and resolving it in the target realm.
 *
 * If the object can be resolved in the target realm, '*resolved' points to the new object
 * If the object cannot be resolved in the target realm, '*resolved' will be null.
 * @return True if no exception occurred (except exceptions that may normally occur if resolution fails)
 */
RLM_API bool realm_object_resolve_in(const realm_object_t* live_object, const realm_t* target_realm,
                                     realm_object_t** resolved);


RLM_API realm_object_t* _realm_object_from_native_copy(const void* pobj, size_t n);
RLM_API realm_object_t* _realm_object_from_native_move(void* pobj, size_t n);
RLM_API const void* _realm_object_get_native_ptr(realm_object_t*);

/**
 * True if this object still exists in the realm.
 *
 * This function cannot fail.
 */
RLM_API bool realm_object_is_valid(const realm_object_t*);

/**
 * Get the key for this object.
 *
 * This function cannot fail.
 */
RLM_API realm_object_key_t realm_object_get_key(const realm_object_t* object);

/**
 * Get the table for this object.
 *
 * This function cannot fail.
 */
RLM_API realm_class_key_t realm_object_get_table(const realm_object_t* object);

/**
 * Get a `realm_link_t` representing a link to @a object.
 *
 * This function cannot fail.
 */
RLM_API realm_link_t realm_object_as_link(const realm_object_t* object);

/**
 * Subscribe to notifications for this object.
 *
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_notification_token_t* realm_object_add_notification_callback(realm_object_t*, void* userdata,
                                                                           realm_free_userdata_func_t free,
                                                                           realm_on_object_change_func_t on_change,
                                                                           realm_callback_error_func_t on_error,
                                                                           realm_scheduler_t*);

/**
 * Get an object from a thread-safe reference, potentially originating in a
 * different `realm_t` instance
 */
RLM_API realm_object_t* realm_object_from_thread_safe_reference(const realm_t*, realm_thread_safe_reference_t*);

/**
 * Get the value for a property.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_get_value(const realm_object_t*, realm_property_key_t, realm_value_t* out_value);

/**
 * Get the values for several properties.
 *
 * This is provided as an alternative to calling `realm_get_value()` multiple
 * times in a row, which is particularly useful for language runtimes where
 * crossing the native bridge is comparatively expensive. In addition, it
 * eliminates some parameter validation that would otherwise be repeated for
 * each call.
 *
 * Example use cases:
 *
 *  - Extracting all properties of an object for serialization.
 *  - Converting an object to some in-memory representation.
 *
 * @param num_values The number of elements in @a properties and @a out_values.
 * @param properties The keys for the properties to fetch. May not be NULL.
 * @param out_values Where to write the property values. If an error occurs,
 *                   this array may only be partially initialized. May not be
 *                   NULL.
 * @return True if no exception occurs.
 */
RLM_API bool realm_get_values(const realm_object_t*, size_t num_values, const realm_property_key_t* properties,
                              realm_value_t* out_values);

/**
 * Set the value for a property.
 *
 * @param new_value The new value for the property.
 * @param is_default True if this property is being set as part of setting the
 *                   default values for a new object. This has no effect in
 *                   non-sync'ed realms.
 * @return True if no exception occurred.
 */
RLM_API bool realm_set_value(realm_object_t*, realm_property_key_t, realm_value_t new_value, bool is_default);

/**
 * Set the values for several properties.
 *
 * This is provided as an alternative to calling `realm_get_value()` multiple
 * times in a row, which is particularly useful for language runtimes where
 * crossing the native bridge is comparatively expensive. In addition, it
 * eliminates some parameter validation that would otherwise be repeated for
 * each call.
 *
 * Example use cases:
 *
 *  - Initializing a new object with default values.
 *  - Deserializing some in-memory structure into a realm object.
 *
 * This operation is "atomic"; if an exception occurs due to invalid input (such
 * as type mismatch, nullability mismatch, etc.), the object will remain
 * unmodified.
 *
 * @param num_values The number of elements in @a properties and @a values.
 * @param properties The keys of the properties to set. May not be NULL.
 * @param values The values to assign to the properties. May not be NULL.
 * @param is_default True if the properties are being set as part of setting
 *                   default values for a new object. This has no effect in
 *                   non-sync'ed realms.
 * @return True if no exception occurred.
 */
RLM_API bool realm_set_values(realm_object_t*, size_t num_values, const realm_property_key_t* properties,
                              const realm_value_t* values, bool is_default);

/**
 * Get a list instance for the property of an object.
 *
 * Note: It is up to the caller to call `realm_release()` on the returned list.
 *
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_list_t* realm_get_list(realm_object_t*, realm_property_key_t);

/**
 * Create a `realm_list_t` from a pointer to a `realm::List`, copy-constructing
 * the internal representation.
 *
 * @param plist A pointer to an instance of `realm::List`.
 * @param n Must be equal to `sizeof(realm::List)`.
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_list_t* _realm_list_from_native_copy(const void* plist, size_t n);

/**
 * Create a `realm_list_t` from a pointer to a `realm::List`, move-constructing
 * the internal representation.
 *
 * @param plist A pointer to an instance of `realm::List`.
 * @param n Must be equal to `sizeof(realm::List)`.
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_list_t* _realm_list_from_native_move(void* plist, size_t n);

/**
 * Resolve the list in the context of a given Realm instance.
 *
 * This is equivalent to producing a thread-safe reference and resolving it in the frozen realm.
 *
 * If resolution is possible, a valid resolved object is produced at '*resolved*'.
 * If resolution is not possible, but no error occurs, '*resolved' is set to NULL
 *
 * @return true if no error occurred.
 */
RLM_API bool realm_list_resolve_in(const realm_list_t* list, const realm_t* target_realm, realm_list_t** resolved);

/**
 * Check if a list is valid.
 *
 * @return True if the list is valid.
 */
RLM_API bool realm_list_is_valid(const realm_list_t*);

/**
 * Get the size of a list, in number of elements.
 *
 * This function may fail if the object owning the list has been deleted.
 *
 * @param out_size Where to put the list size. May be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_size(const realm_list_t*, size_t* out_size);

/**
 * Get the property that this list came from.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_get_property(const realm_list_t*, realm_property_info_t* out_property_info);

/**
 * Get the value at @a index.
 *
 * @param out_value The resulting value, if no error occurred. May be NULL,
 *                  though nonsensical.
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_get(const realm_list_t*, size_t index, realm_value_t* out_value);

/**
 * Set the value at @a index.
 *
 * @param value The value to set.
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_set(realm_list_t*, size_t index, realm_value_t value);

/**
 * Insert @a value at @a index.
 *
 * @param value The value to insert.
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_insert(realm_list_t*, size_t index, realm_value_t value);

/**
 * Erase the element at @a index.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_erase(realm_list_t*, size_t index);

/**
 * Clear a list, removing all elements in the list. In a list of links, this
 * does *NOT* delete the target objects.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_clear(realm_list_t*);

/**
 * In a list of objects, delete all objects in the list and clear the list. In a
 * list of values, clear the list.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_remove_all(realm_list_t*);

/**
 * Replace the contents of a list with values.
 *
 * This is equivalent to calling `realm_list_clear()`, and then
 * `realm_list_insert()` repeatedly.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_list_assign(realm_list_t*, const realm_value_t* values, size_t num_values);

/**
 * Subscribe to notifications for this object.
 *
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_notification_token_t* realm_list_add_notification_callback(realm_list_t*, void* userdata,
                                                                         realm_free_userdata_func_t free,
                                                                         realm_on_collection_change_func_t on_change,
                                                                         realm_callback_error_func_t on_error,
                                                                         realm_scheduler_t*);

/**
 * Get an list from a thread-safe reference, potentially originating in a
 * different `realm_t` instance
 */
RLM_API realm_list_t* realm_list_from_thread_safe_reference(const realm_t*, realm_thread_safe_reference_t*);

/**
 * True if an object notification indicates that the object was deleted.
 *
 * This function cannot fail.
 */
RLM_API bool realm_object_changes_is_deleted(const realm_object_changes_t*);

/**
 * Get the number of properties that were modified in an object notification.
 *
 * This function cannot fail.
 */
RLM_API size_t realm_object_changes_get_num_modified_properties(const realm_object_changes_t*);

/**
 * Get the column keys for the properties that were modified in an object
 * notification.
 *
 * This function cannot fail.
 *
 * @param out_modified Where the column keys should be written. May be NULL.
 * @param max The maximum number of column keys to write.
 * @return The number of column keys written to @a out_modified, or the number
 *         of modified properties if @a out_modified is NULL.
 */
RLM_API size_t realm_object_changes_get_modified_properties(const realm_object_changes_t*,
                                                            realm_property_key_t* out_modified, size_t max);

/**
 * Get the number of various types of changes in a collection notification.
 *
 * @param out_num_deletions The number of deletions. May be NULL.
 * @param out_num_insertions The number of insertions. May be NULL.
 * @param out_num_modifications The number of modifications. May be NULL.
 * @param out_num_moves The number of moved elements. May be NULL.
 */
RLM_API void realm_collection_changes_get_num_changes(const realm_collection_changes_t*, size_t* out_num_deletions,
                                                      size_t* out_num_insertions, size_t* out_num_modifications,
                                                      size_t* out_num_moves);

/**
 * Get the number of various types of changes in a collection notification,
 * suitable for acquiring the change indices as ranges, which is much more
 * compact in memory than getting the individual indices when multiple adjacent
 * elements have been modified.
 *
 * @param out_num_deletion_ranges The number of deleted ranges. May be NULL.
 * @param out_num_insertion_ranges The number of inserted ranges. May be NULL.
 * @param out_num_modification_ranges The number of modified ranges. May be
 *                                    NULL.
 * @param out_num_moves The number of moved elements. May be NULL.
 */
RLM_API void realm_collection_changes_get_num_ranges(const realm_collection_changes_t*,
                                                     size_t* out_num_deletion_ranges,
                                                     size_t* out_num_insertion_ranges,
                                                     size_t* out_num_modification_ranges, size_t* out_num_moves);

typedef struct realm_collection_move {
    size_t from;
    size_t to;
} realm_collection_move_t;

typedef struct realm_index_range {
    size_t from;
    size_t to;
} realm_index_range_t;

/**
 * Get the indices of changes in a collection notification.
 *
 * Note: For moves, every `from` index will also be present among deletions, and
 *       every `to` index will also be present among insertions.
 *
 * This function cannot fail.
 *
 * @param out_deletion_indices Where to put the indices of deleted elements
 *                             (*before* the deletion happened). May be NULL.
 * @param max_deletion_indices The max number of indices to write to @a
 *                             out_deletion_indices.
 * @param out_insertion_indices Where the put the indices of inserted elements
 *                              (*after* the insertion happened). May be NULL.
 * @param max_insertion_indices The max number of indices to write to @a
 *                              out_insertion_indices.
 * @param out_modification_indices Where to put the indices of modified elements
 *                                 (*before* any insertions or deletions of
 *                                 other elements). May be NULL.
 * @param max_modification_indices The max number of indices to write to @a
 *                                 out_modification_indices.
 * @param out_modification_indices_after Where to put the indices of modified
 *                                       elements (*after* any insertions or
 *                                       deletions of other elements). May be
 *                                       NULL.
 * @param max_modification_indices_after The max number of indices to write to
 *                                       @a out_modification_indices_after.
 * @param out_moves Where to put the pairs of indices of moved elements. May be
 *                  NULL.
 * @param max_moves The max number of pairs to write to @a out_moves.
 */
RLM_API void realm_collection_changes_get_changes(const realm_collection_changes_t*, size_t* out_deletion_indices,
                                                  size_t max_deletion_indices, size_t* out_insertion_indices,
                                                  size_t max_insertion_indices, size_t* out_modification_indices,
                                                  size_t max_modification_indices,
                                                  size_t* out_modification_indices_after,
                                                  size_t max_modification_indices_after,
                                                  realm_collection_move_t* out_moves, size_t max_moves);

RLM_API void realm_collection_changes_get_ranges(
    const realm_collection_changes_t*, realm_index_range_t* out_deletion_ranges, size_t max_deletion_ranges,
    realm_index_range_t* out_insertion_ranges, size_t max_insertion_ranges,
    realm_index_range_t* out_modification_ranges, size_t max_modification_ranges,
    realm_index_range_t* out_modification_ranges_after, size_t max_modification_ranges_after,
    realm_collection_move_t* out_moves, size_t max_moves);

RLM_API realm_set_t* _realm_set_from_native_copy(const void* pset, size_t n);
RLM_API realm_set_t* _realm_set_from_native_move(void* pset, size_t n);
RLM_API realm_set_t* realm_get_set(const realm_object_t*, realm_property_key_t);
RLM_API size_t realm_set_size(const realm_set_t*);
RLM_API bool realm_set_get(const realm_set_t*, size_t index, realm_value_t* out_value);
RLM_API bool realm_set_find(const realm_set_t*, realm_value_t value, size_t* out_index);
RLM_API bool realm_set_insert(realm_set_t*, realm_value_t value, size_t out_index);
RLM_API bool realm_set_erase(realm_set_t*, realm_value_t value, bool* out_erased);
RLM_API bool realm_set_clear(realm_set_t*);
RLM_API bool realm_set_assign(realm_set_t*, realm_value_t values, size_t num_values);
RLM_API realm_notification_token_t* realm_set_add_notification_callback(realm_object_t*, void* userdata,
                                                                        realm_free_userdata_func_t free,
                                                                        realm_on_collection_change_func_t on_change,
                                                                        realm_callback_error_func_t on_error,
                                                                        realm_scheduler_t*);


RLM_API realm_dictionary_t* _realm_dictionary_from_native_copy(const void* pdict, size_t n);
RLM_API realm_dictionary_t* _realm_dictionary_from_native_move(void* pdict, size_t n);
RLM_API realm_dictionary_t* realm_get_dictionary(const realm_object_t*, realm_property_key_t);
RLM_API size_t realm_dictionary_size(const realm_dictionary_t*);
RLM_API bool realm_dictionary_get(const realm_dictionary_t*, realm_value_t key, realm_value_t* out_value,
                                  bool* out_found);
RLM_API bool realm_dictionary_insert(realm_dictionary_t*, realm_value_t key, realm_value_t value, bool* out_inserted,
                                     size_t* out_index);
RLM_API bool realm_dictionary_erase(realm_dictionary_t*, realm_value_t key, bool* out_erased);
RLM_API bool realm_dictionary_clear(realm_dictionary_t*);
typedef realm_value_t realm_key_value_pair_t[2];
RLM_API bool realm_dictionary_assign(realm_dictionary_t*, const realm_key_value_pair_t* pairs, size_t num_pairs);
RLM_API realm_notification_token_t*
realm_dictionary_add_notification_callback(realm_object_t*, void* userdata, realm_free_userdata_func_t free,
                                           realm_on_collection_change_func_t on_change,
                                           realm_callback_error_func_t on_error, realm_scheduler_t*);

/**
 * Parse a query string and bind it to a table.
 *
 * If the query failed to parse, the parser error is available from
 * `realm_get_last_error()`.
 *
 * @param target_table The table on which to run this query.
 * @param query_string A zero-terminated string in the Realm Query Language,
 *                     optionally containing argument placeholders (`$0`, `$1`,
 *                     etc.).
 * @param num_args The number of arguments for this query.
 * @param args A pointer to a list of argument values.
 * @return A non-null pointer if the query was successfully parsed and no
 *         exception occurred.
 */
RLM_API realm_query_t* realm_query_parse(const realm_t*, realm_class_key_t target_table, const char* query_string,
                                         size_t num_args, const realm_value_t* args);


/**
 * Parse a query string and append it to an existing query via logical &&.
 * The query string applies to the same table and Realm as the existing query.
 *
 * If the query failed to parse, the parser error is available from
 * `realm_get_last_error()`.
 *
 * @param query_string A zero-terminated string in the Realm Query Language,
 *                     optionally containing argument placeholders (`$0`, `$1`,
 *                     etc.).
 * @param num_args The number of arguments for this query.
 * @param args A pointer to a list of argument values.
 * @return A non-null pointer if the query was successfully parsed and no
 *         exception occurred.
 */
RLM_API realm_query_t* realm_query_append_query(const realm_query_t*, const char* query_string, size_t num_args,
                                                const realm_value_t* args);

/**
 * Parse a query string and bind it to a list.
 *
 * If the query failed to parse, the parser error is available from
 * `realm_get_last_error()`.
 *
 * @param target_list The list on which to run this query.
 * @param query_string A string in the Realm Query Language, optionally
 *                     containing argument placeholders (`$0`, `$1`, etc.).
 * @param num_args The number of arguments for this query.
 * @param args A pointer to a list of argument values.
 * @return A non-null pointer if the query was successfully parsed and no
 *         exception occurred.
 */
RLM_API realm_query_t* realm_query_parse_for_list(const realm_list_t* target_list, const char* query_string,
                                                  size_t num_args, const realm_value_t* args);

/**
 * Parse a query string and bind it to another query result.
 *
 * If the query failed to parse, the parser error is available from
 * `realm_get_last_error()`.
 *
 * @param target_results The results on which to run this query.
 * @param query_string A zero-terminated string in the Realm Query Language,
 *                     optionally containing argument placeholders (`$0`, `$1`,
 *                     etc.).
 * @param num_args The number of arguments for this query.
 * @param args A pointer to a list of argument values.
 * @return A non-null pointer if the query was successfully parsed and no
 *         exception occurred.
 */
RLM_API realm_query_t* realm_query_parse_for_results(const realm_results_t* target_results, const char* query_string,
                                                     size_t num_args, const realm_value_t* args);

/**
 * Count the number of objects found by this query.
 */
RLM_API bool realm_query_count(const realm_query_t*, size_t* out_count);

/**
 * Return the first object matched by this query.
 *
 * Note: This function can only produce objects, not values. Use the
 *       `realm_results_t` returned by `realm_query_find_all()` to retrieve
 *       values from a list of primitive values.
 *
 * @param out_value Where to write the result, if any object matched the query.
 *                  May be NULL.
 * @param out_found Where to write whether the object was found. May be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_query_find_first(realm_query_t*, realm_value_t* out_value, bool* out_found);

/**
 * Produce a results object for this query.
 *
 * Note: This does not actually run the query until the results are accessed in
 *       some way.
 *
 * @return A non-null pointer if no exception occurred.
 */
RLM_API realm_results_t* realm_query_find_all(realm_query_t*);

/**
 * Delete all objects matched by a query.
 */
RLM_API bool realm_query_delete_all(const realm_query_t*);

/**
 * Count the number of results.
 *
 * If the result is "live" (not a snapshot), this may rerun the query if things
 * have changed.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_count(realm_results_t*, size_t* out_count);

/**
 * Get the matching element at @a index in the results.
 *
 * If the result is "live" (not a snapshot), this may rerun the query if things
 * have changed.
 *
 * Note: The bound returned by `realm_results_count()` for a non-snapshot result
 *       is not a reliable way to iterate over elements in the result, because
 *       the result will be live-updated if changes are made in each iteration
 *       that may change the number of query results or even change the
 *       ordering. In other words, this method should probably only be used with
 *       snapshot results.
 *
 * @return True if no exception occurred (including out-of-bounds).
 */
RLM_API bool realm_results_get(realm_results_t*, size_t index, realm_value_t* out_value);

/**
 * Get the matching object at @a index in the results.
 *
 * If the result is "live" (not a snapshot), this may rerun the query if things
 * have changed.
 *
 * Note: The bound returned by `realm_results_count()` for a non-snapshot result
 *       is not a reliable way to iterate over elements in the result, because
 *       the result will be live-updated if changes are made in each iteration
 *       that may change the number of query results or even change the
 *       ordering. In other words, this method should probably only be used with
 *       snapshot results.
 *
 * @return An instance of `realm_object_t` if no exception occurred.
 */
RLM_API realm_object_t* realm_results_get_object(realm_results_t*, size_t index);

/**
 * Delete all objects in the result.
 *
 * If the result if "live" (not a snapshot), this may rerun the query if things
 * have changed.
 *
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_delete_all(realm_results_t*);

/**
 * Return a snapshot of the results that never automatically updates.
 *
 * The returned result is suitable for use with `realm_results_count()` +
 * `realm_results_get()`.
 */
RLM_API realm_results_t* realm_results_snapshot(const realm_results_t*);

/**
 * Map the Results into a live Realm instance.
 *
 * This is equivalent to producing a thread-safe reference and resolving it in the live realm.
 *
 * @return A live copy of the Results.
 */
RLM_API realm_results_t* realm_results_resolve_in(realm_results_t* from_results, const realm_t* target_realm);

/**
 * Compute the minimum value of a property in the results.
 *
 * @param out_min Where to write the result, if there were matching rows.
 * @param out_found Set to true if there are matching rows.
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_min(realm_results_t*, realm_property_key_t, realm_value_t* out_min, bool* out_found);

/**
 * Compute the maximum value of a property in the results.
 *
 * @param out_max Where to write the result, if there were matching rows.
 * @param out_found Set to true if there are matching rows.
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_max(realm_results_t*, realm_property_key_t, realm_value_t* out_max, bool* out_found);

/**
 * Compute the sum value of a property in the results.
 *
 * @param out_sum Where to write the result. Zero if no rows matched.
 * @param out_found Set to true if there are matching rows.
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_sum(realm_results_t*, realm_property_key_t, realm_value_t* out_sum, bool* out_found);

/**
 * Compute the average value of a property in the results.
 *
 * Note: For numeric columns, the average is always converted to double.
 *
 * @param out_average Where to write the result.
 * @param out_found Set to true if there are matching rows.
 * @return True if no exception occurred.
 */
RLM_API bool realm_results_average(realm_results_t*, realm_property_key_t, realm_value_t* out_average,
                                   bool* out_found);

RLM_API realm_notification_token_t* realm_results_add_notification_callback(realm_results_t*, void* userdata,
                                                                            realm_free_userdata_func_t,
                                                                            realm_on_collection_change_func_t,
                                                                            realm_callback_error_func_t,
                                                                            realm_scheduler_t*);

/**
 * Get an results object from a thread-safe reference, potentially originating
 * in a different `realm_t` instance
 */
RLM_API realm_results_t* realm_results_from_thread_safe_reference(const realm_t*, realm_thread_safe_reference_t*);

/* Logging */
// equivalent to realm::util::Logger::Level in util/logger.hpp and must be kept in sync.
typedef enum realm_log_level {
    RLM_LOG_LEVEL_ALL = 0,
    RLM_LOG_LEVEL_TRACE = 1,
    RLM_LOG_LEVEL_DEBUG = 2,
    RLM_LOG_LEVEL_DETAIL = 3,
    RLM_LOG_LEVEL_INFO = 4,
    RLM_LOG_LEVEL_WARNING = 5,
    RLM_LOG_LEVEL_ERROR = 6,
    RLM_LOG_LEVEL_FATAL = 7,
    RLM_LOG_LEVEL_OFF = 8,
} realm_log_level_e;

typedef void (*realm_log_func_t)(void* userdata, realm_log_level_e level, const char* message);

/* HTTP transport */
typedef enum realm_http_request_method {
    RLM_HTTP_REQUEST_METHOD_GET,
    RLM_HTTP_REQUEST_METHOD_POST,
    RLM_HTTP_REQUEST_METHOD_PATCH,
    RLM_HTTP_REQUEST_METHOD_PUT,
    RLM_HTTP_REQUEST_METHOD_DELETE,
} realm_http_request_method_e;

typedef struct realm_http_header {
    const char* name;
    const char* value;
} realm_http_header_t;

typedef struct realm_http_request {
    realm_http_request_method_e method;
    const char* url;
    uint64_t timeout_ms;
    const realm_http_header_t* headers;
    size_t num_headers;
    const char* body;
    size_t body_size;
} realm_http_request_t;

typedef struct realm_http_response {
    int status_code;
    int custom_status_code;
    const realm_http_header_t* headers;
    size_t num_headers;
    const char* body;
    size_t body_size;
} realm_http_response_t;

/**
 * Callback function used by Core to make a HTTP request.
 *
 * Complete the request by calling realm_http_transport_complete_request(),
 * passing in the request_context pointer here and the received response.
 * Network request are expected to be asynchronous and can be completed on any thread.
 *
 * @param userdata The userdata pointer passed to realm_http_transport_new().
 * @param request The request to send.
 * @param request_context Internal state pointer of Core, needed by realm_http_transport_complete_request().
 */
typedef void (*realm_http_request_func_t)(void* userdata, const realm_http_request_t request, void* request_context);

typedef struct realm_http_transport realm_http_transport_t;

/**
 * Create a new HTTP transport with these callbacks implementing its functionality.
 */
RLM_API realm_http_transport_t* realm_http_transport_new(realm_http_request_func_t, void* userdata,
                                                         realm_free_userdata_func_t);

/**
 * Complete a HTTP request with the given response.
 *
 * @param request_context Internal state pointer passed by Core when invoking realm_http_request_func_t
 *                        to start the request.
 * @param response The server response to the HTTP request initiated by Core.
 */
RLM_API void realm_http_transport_complete_request(void* request_context, const realm_http_response_t* response);

/* App */
typedef struct realm_app realm_app_t;
typedef struct realm_app_credentials realm_app_credentials_t;
typedef struct realm_user realm_user_t;

typedef enum realm_user_state {
    RLM_USER_STATE_LOGGED_OUT,
    RLM_USER_STATE_LOGGED_IN,
    RLM_USER_STATE_REMOVED
} realm_user_state_e;

/**
 * Possible error categories the realm_app_error_t error code can fall in.
 */
typedef enum realm_app_error_category {
    /**
     * Error category for HTTP-related errors. The error code value can be interpreted as a HTTP status code.
     */
    RLM_APP_ERROR_CATEGORY_HTTP,
    /**
     * JSON response parsing related errors. The error code is a member of realm_app_errno_json_e.
     */
    RLM_APP_ERROR_CATEGORY_JSON,
    /**
     * Client-side related errors. The error code is a member of realm_app_errno_client_e.
     */
    RLM_APP_ERROR_CATEGORY_CLIENT,
    /**
     * Errors reported by the backend. The error code is a member of realm_app_errno_service_e.
     */
    RLM_APP_ERROR_CATEGORY_SERVICE,
    /**
     * Custom error code was set in realm_http_response_t.custom_status_code.
     * The error code is the custom_status_code value.
     */
    RLM_APP_ERROR_CATEGORY_CUSTOM,
} realm_app_error_category_e;

typedef enum realm_app_errno_json {
    RLM_APP_ERR_JSON_BAD_TOKEN = 1,
    RLM_APP_ERR_JSON_MALFORMED_JSON = 2,
    RLM_APP_ERR_JSON_MISSING_JSON_KEY = 3,
    RLM_APP_ERR_JSON_BAD_BSON_PARSE = 4
} realm_app_errno_json_e;

typedef enum realm_app_errno_client {
    RLM_APP_ERR_CLIENT_USER_NOT_FOUND = 1,
    RLM_APP_ERR_CLIENT_USER_NOT_LOGGED_IN = 2,
    RLM_APP_ERR_CLIENT_APP_DEALLOCATED = 3
} realm_app_errno_client_e;

typedef enum realm_app_errno_service {
    RLM_APP_ERR_SERVICE_MISSING_AUTH_REQ = 1,
    RLM_APP_ERR_SERVICE_INVALID_SESSION = 2,
    RLM_APP_ERR_SERVICE_USER_APP_DOMAIN_MISMATCH = 3,
    RLM_APP_ERR_SERVICE_DOMAIN_NOT_ALLOWED = 4,
    RLM_APP_ERR_SERVICE_READ_SIZE_LIMIT_EXCEEDED = 5,
    RLM_APP_ERR_SERVICE_INVALID_PARAMETER = 6,
    RLM_APP_ERR_SERVICE_MISSING_PARAMETER = 7,
    RLM_APP_ERR_SERVICE_TWILIO_ERROR = 8,
    RLM_APP_ERR_SERVICE_GCM_ERROR = 9,
    RLM_APP_ERR_SERVICE_HTTP_ERROR = 10,
    RLM_APP_ERR_SERVICE_AWS_ERROR = 11,
    RLM_APP_ERR_SERVICE_MONGODB_ERROR = 12,
    RLM_APP_ERR_SERVICE_ARGUMENTS_NOT_ALLOWED = 13,
    RLM_APP_ERR_SERVICE_FUNCTION_EXECUTION_ERROR = 14,
    RLM_APP_ERR_SERVICE_NO_MATCHING_RULE_FOUND = 15,
    RLM_APP_ERR_SERVICE_INTERNAL_SERVER_ERROR = 16,
    RLM_APP_ERR_SERVICE_AUTH_PROVIDER_NOT_FOUND = 17,
    RLM_APP_ERR_SERVICE_AUTH_PROVIDER_ALREADY_EXISTS = 18,
    RLM_APP_ERR_SERVICE_SERVICE_NOT_FOUND = 19,
    RLM_APP_ERR_SERVICE_SERVICE_TYPE_NOT_FOUND = 20,
    RLM_APP_ERR_SERVICE_SERVICE_ALREADY_EXISTS = 21,
    RLM_APP_ERR_SERVICE_SERVICE_COMMAND_NOT_FOUND = 22,
    RLM_APP_ERR_SERVICE_VALUE_NOT_FOUND = 23,
    RLM_APP_ERR_SERVICE_VALUE_ALREADY_EXISTS = 24,
    RLM_APP_ERR_SERVICE_VALUE_DUPLICATE_NAME = 25,
    RLM_APP_ERR_SERVICE_FUNCTION_NOT_FOUND = 26,
    RLM_APP_ERR_SERVICE_FUNCTION_ALREADY_EXISTS = 27,
    RLM_APP_ERR_SERVICE_FUNCTION_DUPLICATE_NAME = 28,
    RLM_APP_ERR_SERVICE_FUNCTION_SYNTAX_ERROR = 29,
    RLM_APP_ERR_SERVICE_FUNCTION_INVALID = 30,
    RLM_APP_ERR_SERVICE_INCOMING_WEBHOOK_NOT_FOUND = 31,
    RLM_APP_ERR_SERVICE_INCOMING_WEBHOOK_ALREADY_EXISTS = 32,
    RLM_APP_ERR_SERVICE_INCOMING_WEBHOOK_DUPLICATE_NAME = 33,
    RLM_APP_ERR_SERVICE_RULE_NOT_FOUND = 34,
    RLM_APP_ERR_SERVICE_API_KEY_NOT_FOUND = 35,
    RLM_APP_ERR_SERVICE_RULE_ALREADY_EXISTS = 36,
    RLM_APP_ERR_SERVICE_RULE_DUPLICATE_NAME = 37,
    RLM_APP_ERR_SERVICE_AUTH_PROVIDER_DUPLICATE_NAME = 38,
    RLM_APP_ERR_SERVICE_RESTRICTED_HOST = 39,
    RLM_APP_ERR_SERVICE_API_KEY_ALREADY_EXISTS = 40,
    RLM_APP_ERR_SERVICE_INCOMING_WEBHOOK_AUTH_FAILED = 41,
    RLM_APP_ERR_SERVICE_EXECUTION_TIME_LIMIT_EXCEEDED = 42,
    RLM_APP_ERR_SERVICE_NOT_CALLABLE = 43,
    RLM_APP_ERR_SERVICE_USER_ALREADY_CONFIRMED = 44,
    RLM_APP_ERR_SERVICE_USER_NOT_FOUND = 45,
    RLM_APP_ERR_SERVICE_USER_DISABLED = 46,
    RLM_APP_ERR_SERVICE_AUTH_ERROR = 47,
    RLM_APP_ERR_SERVICE_BAD_REQUEST = 48,
    RLM_APP_ERR_SERVICE_ACCOUNT_NAME_IN_USE = 49,
    RLM_APP_ERR_SERVICE_INVALID_EMAIL_PASSWORD = 50,

    RLM_APP_ERR_SERVICE_UNKNOWN = -1,
    RLM_APP_ERR_SERVICE_NONE = 0
} realm_app_errno_service_e;

typedef enum realm_auth_provider {
    RLM_AUTH_PROVIDER_ANONYMOUS,
    RLM_AUTH_PROVIDER_FACEBOOK,
    RLM_AUTH_PROVIDER_GOOGLE,
    RLM_AUTH_PROVIDER_APPLE,
    RLM_AUTH_PROVIDER_CUSTOM,
    RLM_AUTH_PROVIDER_EMAIL_PASSWORD,
    RLM_AUTH_PROVIDER_FUNCTION,
    RLM_AUTH_PROVIDER_USER_API_KEY,
    RLM_AUTH_PROVIDER_SERVER_API_KEY,
} realm_auth_provider_e;

typedef struct realm_app_user_apikey {
    realm_object_id_t id;
    const char* key;
    const char* name;
    bool disabled;
} realm_app_user_apikey_t;

// This type should never be returned from a function.
// It's only meant as an asynchronous callback argument.
// Pointers to this struct and its pointer members are only valid inside the scope
// of the callback they were passed to.
typedef struct realm_app_error {
    realm_app_error_category_e error_category;
    int error_code;

    /**
     * The underlying HTTP status code returned by the server,
     * otherwise zero.
     */
    int http_status_code;

    const char* message;

    /**
     * A link to MongoDB Realm server logs related to the error,
     * or NULL if error response didn't contain log information.
     */
    const char* link_to_server_logs;
} realm_app_error_t;

/**
 * Generic completion callback for asynchronous Realm App operations.
 *
 * @param userdata The userdata pointer the asynchronous operation was started with.
 * @param error Pointer to an error object if the operation failed, otherwise null if it completed successfully.
 */
typedef void (*realm_app_void_completion_func_t)(void* userdata, const realm_app_error_t* error);

/**
 * Completion callback for asynchronous Realm App operations that yield a user object.
 *
 * @param userdata The userdata pointer the asynchronous operation was started with.
 * @param user User object produced by the operation, or null if it failed.
 *             The pointer is alive only for the duration of the callback,
 *             if you wish to use it further make a copy with realm_clone().
 * @param error Pointer to an error object if the operation failed, otherwise null if it completed successfully.
 */
typedef void (*realm_app_user_completion_func_t)(void* userdata, realm_user_t* user, const realm_app_error_t* error);

RLM_API realm_app_credentials_t* realm_app_credentials_new_anonymous(void) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_facebook(const char* access_token) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_google(const char* id_token) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_apple(const char* id_token) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_jwt(const char* jwt_token) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_email_password(const char* email,
                                                                          realm_string_t password) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_user_api_key(const char* api_key) RLM_API_NOEXCEPT;
RLM_API realm_app_credentials_t* realm_app_credentials_new_server_api_key(const char* api_key) RLM_API_NOEXCEPT;

/**
 * Create Custom Function authentication app credentials.
 *
 * @param serialized_ejson_payload The arguments array to invoke the function with,
 *                                 serialized as an Extended JSON string.
 * @return null, if an error occurred.
 */
RLM_API realm_app_credentials_t* realm_app_credentials_new_function(const char* serialized_ejson_payload);

RLM_API realm_auth_provider_e realm_auth_credentials_get_provider(realm_app_credentials_t*) RLM_API_NOEXCEPT;

/**
 * Create a new app configuration.
 *
 * @param app_id The MongoDB Realm app id.
 * @param http_transport The HTTP transport used to make network calls.
 */
RLM_API realm_app_config_t* realm_app_config_new(const char* app_id,
                                                 const realm_http_transport_t* http_transport) RLM_API_NOEXCEPT;

RLM_API void realm_app_config_set_base_url(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_local_app_name(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_local_app_version(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_default_request_timeout(realm_app_config_t*, uint64_t ms) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_platform(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_platform_version(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_app_config_set_sdk_version(realm_app_config_t*, const char*) RLM_API_NOEXCEPT;

/**
 * Get an existing @a realm_app_t* instance with the same app id, or create it with the
 * configuration if it doesn't exist.
 *
 * @return A non-null pointer if no error occurred.
 */
RLM_API realm_app_t* realm_app_get(const realm_app_config_t*, const realm_sync_client_config_t*);

/**
 * Get an existing @a realm_app_t* instance from the cache.
 *
 * @return Cached app instance, or null if no cached app exists for this @a app_id.
 */
RLM_API realm_app_t* realm_app_get_cached(const char* app_id) RLM_API_NOEXCEPT;

/**
 * Clear all the cached @a realm_app_t* instances in the process.
 *
 * @a realm_app_t* instances will need to be disposed with realm_release()
 * for them to be fully destroyed after the cache is cleared.
 */
RLM_API void realm_clear_cached_apps(void) RLM_API_NOEXCEPT;

RLM_API const char* realm_app_get_app_id(const realm_app_t*) RLM_API_NOEXCEPT;
RLM_API realm_user_t* realm_app_get_current_user(const realm_app_t*) RLM_API_NOEXCEPT;

/**
 * Get the list of active users in this @a app.
 *
 * @param out_users A pointer to an array of `realm_user_t*`, which
 *                  will be populated with the list of active users in the app.
 *                  May be NULL, in which case this function can be used to
 *                  discover the number of active users by passing in just `out_n`.
 * @param capacity The maximum number of elements `out_users` can hold.
 * @param out_n The actual number of entries written to `out_users`.
 *              May be NULL.
 * @return True if no exception occurred.
 */
RLM_API bool realm_app_get_all_users(const realm_app_t* app, realm_user_t** out_users, size_t capacity,
                                     size_t* out_n);

RLM_API bool realm_app_log_in_with_credentials(realm_app_t*, realm_app_credentials_t*,
                                               realm_app_user_completion_func_t, void* userdata,
                                               realm_free_userdata_func_t);

RLM_API bool realm_app_log_out_current_user(realm_app_t*, realm_app_void_completion_func_t, void* userdata,
                                            realm_free_userdata_func_t);

RLM_API bool realm_app_refresh_custom_data(realm_app_t*, realm_user_t*, realm_app_void_completion_func_t,
                                           void* userdata, realm_free_userdata_func_t);

RLM_API bool realm_app_log_out(realm_app_t*, realm_user_t*, realm_app_void_completion_func_t, void* userdata,
                               realm_free_userdata_func_t);

RLM_API bool realm_app_link_user(realm_app_t*, realm_user_t*, realm_app_credentials_t*,
                                 realm_app_user_completion_func_t, void* userdata, realm_free_userdata_func_t);

RLM_API bool realm_app_switch_user(realm_app_t*, realm_user_t*, realm_user_t** new_user);

RLM_API bool realm_app_remove_user(realm_app_t*, realm_user_t*, realm_app_void_completion_func_t, void* userdata,
                                   realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_register_email(realm_app_t*, const char* email,
                                                                     realm_string_t password,
                                                                     realm_app_void_completion_func_t, void* userdata,
                                                                     realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_confirm_user(realm_app_t*, const char* token,
                                                                   const char* token_id,
                                                                   realm_app_void_completion_func_t, void* userdata,
                                                                   realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_resend_confirmation_email(realm_app_t*, const char* email,
                                                                                realm_app_void_completion_func_t,
                                                                                void* userdata,
                                                                                realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_send_reset_password_email(realm_app_t*, const char* email,
                                                                                realm_app_void_completion_func_t,
                                                                                void* userdata,
                                                                                realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_retry_custom_confirmation(realm_app_t*, const char* email,
                                                                                realm_app_void_completion_func_t,
                                                                                void* userdata,
                                                                                realm_free_userdata_func_t);

RLM_API bool realm_app_email_password_provider_client_reset_password(realm_app_t*, realm_string_t password,
                                                                     const char* token, const char* token_id,
                                                                     realm_app_void_completion_func_t, void* userdata,
                                                                     realm_free_userdata_func_t);

/**
 * Run the Email/Password Authentication provider's password reset function.
 *
 * @param serialized_ejson_payload The arguments array to invoke the function with,
 *                                 serialized as an Extended JSON string.
 * @return true, if no error occurred.
 */
RLM_API bool realm_app_email_password_provider_client_call_reset_password_function(
    realm_app_t*, const char* email, realm_string_t password, const char* serialized_ejson_payload,
    realm_app_void_completion_func_t, void* userdata, realm_free_userdata_func_t);


RLM_API bool realm_app_user_apikey_provider_client_create_apikey(const realm_app_t*, const realm_user_t*,
                                                                 const char* name,
                                                                 void (*)(void* userdata, realm_app_user_apikey_t*,
                                                                          const realm_app_error_t*),
                                                                 void* userdata, realm_free_userdata_func_t);

RLM_API bool realm_app_user_apikey_provider_client_fetch_apikey(const realm_app_t*, const realm_user_t*,
                                                                realm_object_id_t id,
                                                                void (*)(void* userdata, realm_app_user_apikey_t*,
                                                                         const realm_app_error_t*),
                                                                void* userdata, realm_free_userdata_func_t);

RLM_API bool realm_app_user_apikey_provider_client_fetch_apikeys(const realm_app_t*, const realm_user_t*,
                                                                 void (*)(void* userdata, realm_app_user_apikey_t[],
                                                                          size_t count, realm_app_error_t*),
                                                                 void* userdata, realm_free_userdata_func_t);

RLM_API bool realm_app_user_apikey_provider_client_delete_apikey(const realm_app_t*, const realm_user_t*,
                                                                 realm_object_id_t id,
                                                                 realm_app_void_completion_func_t, void* userdata,
                                                                 realm_free_userdata_func_t);

RLM_API bool realm_app_user_apikey_provider_client_enable_apikey(const realm_app_t*, const realm_user_t*,
                                                                 realm_object_id_t id,
                                                                 realm_app_void_completion_func_t, void* userdata,
                                                                 realm_free_userdata_func_t);

RLM_API bool realm_app_user_apikey_provider_client_disable_apikey(const realm_app_t*, const realm_user_t*,
                                                                  realm_object_id_t id,
                                                                  realm_app_void_completion_func_t, void* userdata,
                                                                  realm_free_userdata_func_t);

RLM_API bool realm_app_push_notification_client_register_device(const realm_app_t*, const realm_user_t*,
                                                                const char* service_name,
                                                                const char* registration_token,
                                                                realm_app_void_completion_func_t, void* userdata,
                                                                realm_free_userdata_func_t);

RLM_API bool realm_app_push_notification_client_deregister_device(const realm_app_t*, const realm_user_t*,
                                                                  const char* service_name,
                                                                  realm_app_void_completion_func_t, void* userdata,
                                                                  realm_free_userdata_func_t);

/**
 * Run a named MongoDB Realm function.
 *
 * @param serialized_ejson_args The arguments array to invoke the function with,
 *                              serialized as an Extended JSON string.
 * @return true, if no error occurred.
 */
RLM_API bool realm_app_call_function(const realm_app_t*, const realm_user_t*, const char* function_name,
                                     const char* serialized_ejson_args,
                                     void (*)(void* userdata, const char* serialized_ejson_response,
                                              const realm_app_error_t*),
                                     void* userdata, realm_free_userdata_func_t);

/**
 * Instruct this app's sync client to immediately reconnect.
 * Useful when the device has been offline and then receives a network reachability update.
 *
 * The sync client will always attempt to reconnect eventually, this is just a hint.
 */
RLM_API void realm_app_sync_client_reconnect(realm_app_t*) RLM_API_NOEXCEPT;

/**
 * Get whether there are any active sync sessions for this app.
 */
RLM_API bool realm_app_sync_client_has_sessions(const realm_app_t*) RLM_API_NOEXCEPT;

/**
 * Wait until the sync client has terminated all sessions and released all realm files
 * it had open.
 *
 * WARNING: this is a blocking wait.
 */
RLM_API void realm_app_sync_client_wait_for_sessions_to_terminate(realm_app_t*) RLM_API_NOEXCEPT;

/**
 * Get the default realm file path based on the user and partition value in the config.
 *
 * @param custom_filename custom name for the realm file itself. Can be null,
 *                        in which case a default name based on the config will be used.
 *
 * Return value must be manually released with realm_free().
 */
RLM_API char* realm_app_sync_client_get_default_file_path_for_realm(const realm_app_t*, const realm_sync_config_t*,
                                                                    const char* custom_filename) RLM_API_NOEXCEPT;

RLM_API const char* realm_user_get_identity(const realm_user_t*) RLM_API_NOEXCEPT;

RLM_API realm_user_state_e realm_user_get_state(const realm_user_t*) RLM_API_NOEXCEPT;

typedef struct {
    const char* id;
    realm_auth_provider_e provider_type;
} realm_user_identity_t;

/**
 * Get the list of identities of this @a user.
 *
 * @param out_identities A pointer to an array of `realm_user_identity_t`, which
 *                       will be populated with the list of identities of this user.
 *                       May be NULL, in which case this function can be used to
 *                       discover the number of identities of this user by passing in NULL here
 *                       and examining `*out_n`.
 * @param capacity The maximum number of elements `out_identities` can hold.
 * @param out_n The actual number of entries written to `out_identities`. May be NULL.
 * @return true, if no errors occurred.
 */
RLM_API bool realm_user_get_all_identities(const realm_user_t* user, realm_user_identity_t* out_identities,
                                           size_t capacity, size_t* out_n);

RLM_API const char* realm_user_get_local_identity(const realm_user_t*) RLM_API_NOEXCEPT;

// returned pointer must be manually released with realm_free()
RLM_API char* realm_user_get_device_id(const realm_user_t*) RLM_API_NOEXCEPT;

RLM_API realm_auth_provider_e realm_user_get_auth_provider(const realm_user_t*) RLM_API_NOEXCEPT;

/**
 * Log out the user and mark it as logged out.
 *
 * Any active sync sessions associated with this user will be stopped.
 *
 * @return true, if no errors occurred.
 */
RLM_API bool realm_user_log_out(realm_user_t*);

RLM_API bool realm_user_is_logged_in(const realm_user_t*) RLM_API_NOEXCEPT;

/**
 * Get the custom user data from the user's access token.
 *
 * Returned value must be manually released with realm_free().
 *
 * @return An Extended JSON document serialized as string,
 *         or null if token doesn't have any custom data.
 */
RLM_API char* realm_user_get_custom_data(const realm_user_t*) RLM_API_NOEXCEPT;

/**
 * Get the user profile associated with this user.
 *
 * Returned value must be manually released with realm_free().
 *
 * @return An Extended JSON document serialized as string,
 *         or null if an error occurred.
 */
RLM_API char* realm_user_get_profile_data(const realm_user_t*);

/* Sync */
typedef enum realm_sync_client_metadata_mode {
    RLM_SYNC_CLIENT_METADATA_MODE_PLAINTEXT,
    RLM_SYNC_CLIENT_METADATA_MODE_ENCRYPTED,
    RLM_SYNC_CLIENT_METADATA_MODE_DISABLED,
} realm_sync_client_metadata_mode_e;

typedef enum realm_sync_client_reconnect_mode {
    RLM_SYNC_CLIENT_RECONNECT_MODE_NORMAL,
    RLM_SYNC_CLIENT_RECONNECT_MODE_TESTING,
} realm_sync_client_reconnect_mode_e;

typedef enum realm_sync_session_resync_mode {
    RLM_SYNC_SESSION_RESYNC_MODE_MANUAL,
    RLM_SYNC_SESSION_RESYNC_MODE_DISCARD_LOCAL,
} realm_sync_session_resync_mode_e;

typedef enum realm_sync_session_stop_policy {
    RLM_SYNC_SESSION_STOP_POLICY_IMMEDIATELY,
    RLM_SYNC_SESSION_STOP_POLICY_LIVE_INDEFINITELY,
    RLM_SYNC_SESSION_STOP_POLICY_AFTER_CHANGES_UPLOADED,
} realm_sync_session_stop_policy_e;

typedef enum realm_sync_session_state {
    RLM_SYNC_SESSION_STATE_ACTIVE,
    RLM_SYNC_SESSION_STATE_DYING,
    RLM_SYNC_SESSION_STATE_INACTIVE,
    RLM_SYNC_SESSION_STATE_WAITING_FOR_ACCESS_TOKEN,
} realm_sync_session_state_e;

typedef enum realm_sync_connection_state {
    RLM_SYNC_CONNECTION_STATE_DISCONNECTED,
    RLM_SYNC_CONNECTION_STATE_CONNECTING,
    RLM_SYNC_CONNECTION_STATE_CONNECTED,
} realm_sync_connection_state_e;

typedef enum realm_sync_progress_direction {
    RLM_SYNC_PROGRESS_DIRECTION_UPLOAD,
    RLM_SYNC_PROGRESS_DIRECTION_DOWNLOAD,
} realm_sync_progress_direction_e;

/**
 * Possible error categories realm_sync_error_code_t can fall in.
 */
typedef enum realm_sync_error_category {
    RLM_SYNC_ERROR_CATEGORY_CLIENT,
    RLM_SYNC_ERROR_CATEGORY_CONNECTION,
    RLM_SYNC_ERROR_CATEGORY_SESSION,

    /**
     * System error - POSIX errno, Win32 HRESULT, etc.
     */
    RLM_SYNC_ERROR_CATEGORY_SYSTEM,

    /**
     * Unknown source of error.
     */
    RLM_SYNC_ERROR_CATEGORY_UNKNOWN,
} realm_sync_error_category_e;

typedef enum realm_sync_errno_client {
    RLM_SYNC_ERR_CLIENT_CONNECTION_CLOSED = 100,
    RLM_SYNC_ERR_CLIENT_UNKNOWN_MESSAGE = 101,
    RLM_SYNC_ERR_CLIENT_BAD_SYNTAX = 102,
    RLM_SYNC_ERR_CLIENT_LIMITS_EXCEEDED = 103,
    RLM_SYNC_ERR_CLIENT_BAD_SESSION_IDENT = 104,
    RLM_SYNC_ERR_CLIENT_BAD_MESSAGE_ORDER = 105,
    RLM_SYNC_ERR_CLIENT_BAD_CLIENT_FILE_IDENT = 106,
    RLM_SYNC_ERR_CLIENT_BAD_PROGRESS = 107,
    RLM_SYNC_ERR_CLIENT_BAD_CHANGESET_HEADER_SYNTAX = 108,
    RLM_SYNC_ERR_CLIENT_BAD_CHANGESET_SIZE = 109,
    RLM_SYNC_ERR_CLIENT_BAD_ORIGIN_FILE_IDENT = 110,
    RLM_SYNC_ERR_CLIENT_BAD_SERVER_VERSION = 111,
    RLM_SYNC_ERR_CLIENT_BAD_CHANGESET = 112,
    RLM_SYNC_ERR_CLIENT_BAD_REQUEST_IDENT = 113,
    RLM_SYNC_ERR_CLIENT_BAD_ERROR_CODE = 114,
    RLM_SYNC_ERR_CLIENT_BAD_COMPRESSION = 115,
    RLM_SYNC_ERR_CLIENT_BAD_CLIENT_VERSION = 116,
    RLM_SYNC_ERR_CLIENT_SSL_SERVER_CERT_REJECTED = 117,
    RLM_SYNC_ERR_CLIENT_PONG_TIMEOUT = 118,
    RLM_SYNC_ERR_CLIENT_BAD_CLIENT_FILE_IDENT_SALT = 119,
    RLM_SYNC_ERR_CLIENT_BAD_FILE_IDENT = 120,
    RLM_SYNC_ERR_CLIENT_CONNECT_TIMEOUT = 121,
    RLM_SYNC_ERR_CLIENT_BAD_TIMESTAMP = 122,
    RLM_SYNC_ERR_CLIENT_BAD_PROTOCOL_FROM_SERVER = 123,
    RLM_SYNC_ERR_CLIENT_CLIENT_TOO_OLD_FOR_SERVER = 124,
    RLM_SYNC_ERR_CLIENT_CLIENT_TOO_NEW_FOR_SERVER = 125,
    RLM_SYNC_ERR_CLIENT_PROTOCOL_MISMATCH = 126,
    RLM_SYNC_ERR_CLIENT_BAD_STATE_MESSAGE = 127,
    RLM_SYNC_ERR_CLIENT_MISSING_PROTOCOL_FEATURE = 128,
    RLM_SYNC_ERR_CLIENT_HTTP_TUNNEL_FAILED = 131,
} realm_sync_errno_client_e;

typedef enum realm_sync_errno_connection {
    RLM_SYNC_ERR_CONNECTION_CONNECTION_CLOSED = 100,
    RLM_SYNC_ERR_CONNECTION_OTHER_ERROR = 101,
    RLM_SYNC_ERR_CONNECTION_UNKNOWN_MESSAGE = 102,
    RLM_SYNC_ERR_CONNECTION_BAD_SYNTAX = 103,
    RLM_SYNC_ERR_CONNECTION_LIMITS_EXCEEDED = 104,
    RLM_SYNC_ERR_CONNECTION_WRONG_PROTOCOL_VERSION = 105,
    RLM_SYNC_ERR_CONNECTION_BAD_SESSION_IDENT = 106,
    RLM_SYNC_ERR_CONNECTION_REUSE_OF_SESSION_IDENT = 107,
    RLM_SYNC_ERR_CONNECTION_BOUND_IN_OTHER_SESSION = 108,
    RLM_SYNC_ERR_CONNECTION_BAD_MESSAGE_ORDER = 109,
    RLM_SYNC_ERR_CONNECTION_BAD_DECOMPRESSION = 110,
    RLM_SYNC_ERR_CONNECTION_BAD_CHANGESET_HEADER_SYNTAX = 111,
    RLM_SYNC_ERR_CONNECTION_BAD_CHANGESET_SIZE = 112,
    RLM_SYNC_ERR_CONNECTION_SWITCH_TO_FLX_SYNC = 113,
    RLM_SYNC_ERR_CONNECTION_SWITCH_TO_PBS = 114,
} realm_sync_errno_connection_e;

typedef enum realm_sync_errno_session {
    RLM_SYNC_ERR_SESSION_SESSION_CLOSED = 200,
    RLM_SYNC_ERR_SESSION_OTHER_SESSION_ERROR = 201,
    RLM_SYNC_ERR_SESSION_TOKEN_EXPIRED = 202,
    RLM_SYNC_ERR_SESSION_BAD_AUTHENTICATION = 203,
    RLM_SYNC_ERR_SESSION_ILLEGAL_REALM_PATH = 204,
    RLM_SYNC_ERR_SESSION_NO_SUCH_REALM = 205,
    RLM_SYNC_ERR_SESSION_PERMISSION_DENIED = 206,
    RLM_SYNC_ERR_SESSION_BAD_SERVER_FILE_IDENT = 207,
    RLM_SYNC_ERR_SESSION_BAD_CLIENT_FILE_IDENT = 208,
    RLM_SYNC_ERR_SESSION_BAD_SERVER_VERSION = 209,
    RLM_SYNC_ERR_SESSION_BAD_CLIENT_VERSION = 210,
    RLM_SYNC_ERR_SESSION_DIVERGING_HISTORIES = 211,
    RLM_SYNC_ERR_SESSION_BAD_CHANGESET = 212,
    RLM_SYNC_ERR_SESSION_SUPERSEDED = 213,
    RLM_SYNC_ERR_SESSION_DISABLED_SESSION = 213,
    RLM_SYNC_ERR_SESSION_PARTIAL_SYNC_DISABLED = 214,
    RLM_SYNC_ERR_SESSION_UNSUPPORTED_SESSION_FEATURE = 215,
    RLM_SYNC_ERR_SESSION_BAD_ORIGIN_FILE_IDENT = 216,
    RLM_SYNC_ERR_SESSION_BAD_CLIENT_FILE = 217,
    RLM_SYNC_ERR_SESSION_SERVER_FILE_DELETED = 218,
    RLM_SYNC_ERR_SESSION_CLIENT_FILE_BLACKLISTED = 219,
    RLM_SYNC_ERR_SESSION_USER_BLACKLISTED = 220,
    RLM_SYNC_ERR_SESSION_TRANSACT_BEFORE_UPLOAD = 221,
    RLM_SYNC_ERR_SESSION_CLIENT_FILE_EXPIRED = 222,
    RLM_SYNC_ERR_SESSION_USER_MISMATCH = 223,
    RLM_SYNC_ERR_SESSION_TOO_MANY_SESSIONS = 224,
    RLM_SYNC_ERR_SESSION_INVALID_SCHEMA_CHANGE = 225,
} realm_sync_errno_session_e;

typedef struct realm_sync_session realm_sync_session_t;
typedef struct realm_async_open_task realm_async_open_task_t;

// This type should never be returned from a function.
// It's only meant as an asynchronous callback argument.
// Pointers to this struct and its pointer members are only valid inside the scope
// of the callback they were passed to.
typedef struct realm_sync_error_code {
    realm_sync_error_category_e category;
    int value;
    const char* message;
} realm_sync_error_code_t;

typedef struct realm_sync_error_user_info {
    const char* key;
    const char* value;
} realm_sync_error_user_info_t;

// This type should never be returned from a function.
// It's only meant as an asynchronous callback argument.
// Pointers to this struct and its pointer members are only valid inside the scope
// of the callback they were passed to.
typedef struct realm_sync_error {
    realm_sync_error_code_t error_code;
    const char* detailed_message;
    bool is_fatal;
    bool is_unrecognized_by_client;

    realm_sync_error_user_info_t* user_info_map;
    size_t user_info_length;
} realm_sync_error_t;

typedef void (*realm_sync_upload_completion_func_t)(void* userdata, realm_sync_error_code_t*);
typedef void (*realm_sync_download_completion_func_t)(void* userdata, realm_sync_error_code_t*);
typedef void (*realm_sync_connection_state_changed_func_t)(void* userdata, realm_sync_connection_state_e old_state,
                                                           realm_sync_connection_state_e new_state);
typedef void (*realm_sync_session_state_changed_func_t)(void* userdata, realm_sync_session_state_e old_state,
                                                        realm_sync_session_state_e new_state);
typedef void (*realm_sync_progress_func_t)(void* userdata, uint64_t transferred_bytes, uint64_t total_bytes);
typedef void (*realm_sync_error_handler_func_t)(void* userdata, realm_sync_session_t*, const realm_sync_error_t);
typedef bool (*realm_sync_ssl_verify_func_t)(void* userdata, const char* server_address, short server_port,
                                             const char* pem_data, size_t pem_size, int preverify_ok, int depth);

/**
 * Callback function invoked by the async open task once the realm is open and fully synchronized.
 *
 * This callback is invoked on the sync client's worker thread.
 *
 * @param realm Downloaded realm instance, or null if an error occurred.
 *              Move to the thread you want to use it on and
 *              thaw with @a realm_from_thread_safe_reference().
 * @param error Null, if the operation complete successfully.
 */
typedef void (*realm_async_open_task_completion_func_t)(void* userdata, realm_thread_safe_reference_t* realm,
                                                        const realm_async_error_t* error);

RLM_API realm_sync_client_config_t* realm_sync_client_config_new(void) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_base_file_path(realm_sync_client_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_metadata_mode(realm_sync_client_config_t*,
                                                        realm_sync_client_metadata_mode_e) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_metadata_encryption_key(realm_sync_client_config_t*,
                                                                  const uint8_t[64]) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_reset_metadata_on_error(realm_sync_client_config_t*, bool) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_log_callback(realm_sync_client_config_t*, realm_log_func_t, void* userdata,
                                                       realm_free_userdata_func_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_log_level(realm_sync_client_config_t*, realm_log_level_e) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_reconnect_mode(realm_sync_client_config_t*,
                                                         realm_sync_client_reconnect_mode_e) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_multiplex_sessions(realm_sync_client_config_t*, bool) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_user_agent_binding_info(realm_sync_client_config_t*,
                                                                  const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_user_agent_application_info(realm_sync_client_config_t*,
                                                                      const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_connect_timeout(realm_sync_client_config_t*, uint64_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_connection_linger_time(realm_sync_client_config_t*,
                                                                 uint64_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_ping_keepalive_period(realm_sync_client_config_t*,
                                                                uint64_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_pong_keepalive_timeout(realm_sync_client_config_t*,
                                                                 uint64_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_client_config_set_fast_reconnect_limit(realm_sync_client_config_t*,
                                                               uint64_t) RLM_API_NOEXCEPT;

RLM_API realm_sync_config_t* realm_sync_config_new(const realm_user_t*, const char* partition_value) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_session_stop_policy(realm_sync_config_t*,
                                                       realm_sync_session_stop_policy_e) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_error_handler(realm_sync_config_t*, realm_sync_error_handler_func_t,
                                                 void* userdata, realm_free_userdata_func_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_client_validate_ssl(realm_sync_config_t*, bool) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_ssl_trust_certificate_path(realm_sync_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_ssl_verify_callback(realm_sync_config_t*, realm_sync_ssl_verify_func_t,
                                                       void* userdata, realm_free_userdata_func_t) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_cancel_waits_on_nonfatal_error(realm_sync_config_t*, bool) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_authorization_header_name(realm_sync_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_custom_http_header(realm_sync_config_t*, const char* name,
                                                      const char* value) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_recovery_directory_path(realm_sync_config_t*, const char*) RLM_API_NOEXCEPT;
RLM_API void realm_sync_config_set_resync_mode(realm_sync_config_t*,
                                               realm_sync_session_resync_mode_e) RLM_API_NOEXCEPT;

/**
 * Create a task that will open a realm with the specific configuration
 * and also download all changes from the sync server.
 *
 * Use @a realm_async_open_task_start() to start the download process.
 */
RLM_API realm_async_open_task_t* realm_open_synchronized(realm_config_t*) RLM_API_NOEXCEPT;
RLM_API void realm_async_open_task_start(realm_async_open_task_t*, realm_async_open_task_completion_func_t,
                                         void* userdata, realm_free_userdata_func_t) RLM_API_NOEXCEPT;
RLM_API void realm_async_open_task_cancel(realm_async_open_task_t*) RLM_API_NOEXCEPT;
RLM_API uint64_t realm_async_open_task_register_download_progress_notifier(
    realm_async_open_task_t*, realm_sync_progress_func_t, void* userdata,
    realm_free_userdata_func_t) RLM_API_NOEXCEPT;
RLM_API void realm_async_open_task_unregister_download_progress_notifier(realm_async_open_task_t*,
                                                                         uint64_t token) RLM_API_NOEXCEPT;

/**
 * Get the sync session for a specific realm.
 *
 * This function will not fail if the realm wasn't open with a sync configuration in place,
 * but just return NULL;
 *
 * @return A non-null pointer if a session exists.
 */
RLM_API realm_sync_session_t* realm_sync_session_get(const realm_t*) RLM_API_NOEXCEPT;

RLM_API realm_sync_session_state_e realm_sync_session_get_state(const realm_sync_session_t*) RLM_API_NOEXCEPT;

RLM_API realm_sync_connection_state_e realm_sync_session_get_connection_state(const realm_sync_session_t*)
    RLM_API_NOEXCEPT;

RLM_API realm_user_t* realm_sync_session_get_user(const realm_sync_session_t*) RLM_API_NOEXCEPT;

RLM_API const char* realm_sync_session_get_partition_value(const realm_sync_session_t*) RLM_API_NOEXCEPT;

/**
 * Get the filesystem path of the realm file backing this session.
 */
RLM_API const char* realm_sync_session_get_file_path(const realm_sync_session_t*) RLM_API_NOEXCEPT;

/**
 * Ask the session to pause synchronization.
 *
 * No-op if the session is already inactive.
 */
RLM_API void realm_sync_session_pause(realm_sync_session_t*) RLM_API_NOEXCEPT;

/**
 * Ask the session to resume synchronization.
 *
 * No-op if the session is already active.
 */
RLM_API void realm_sync_session_resume(realm_sync_session_t*) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked every time the session's connection state changes.
 *
 * @return A token value that can be used to unregiser the callback.
 */
RLM_API uint64_t realm_sync_session_register_connection_state_change_callback(
    realm_sync_session_t*, realm_sync_connection_state_changed_func_t, void* userdata,
    realm_free_userdata_func_t userdata_free) RLM_API_NOEXCEPT;

RLM_API void realm_sync_session_unregister_connection_state_change_callback(realm_sync_session_t*,
                                                                            uint64_t token) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked every time the session reports progress.
 *
 * @param is_streaming If true, then the notifier will be called forever, and will
 *                     always contain the most up-to-date number of downloadable or uploadable bytes.
 *                     Otherwise, the number of downloaded or uploaded bytes will always be reported
 *                     relative to the number of downloadable or uploadable bytes at the point in time
 *                     when the notifier was registered.
 * @return A token value that can be used to unregiser the notifier.
 */
RLM_API uint64_t realm_sync_session_register_progress_notifier(
    realm_sync_session_t*, realm_sync_progress_func_t, realm_sync_progress_direction_e, bool is_streaming,
    void* userdata, realm_free_userdata_func_t userdata_free) RLM_API_NOEXCEPT;

RLM_API void realm_sync_session_unregister_progress_notifier(realm_sync_session_t*, uint64_t token) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked when all pending downloads have completed.
 */
RLM_API void
realm_sync_session_wait_for_download_completion(realm_sync_session_t*, realm_sync_download_completion_func_t,
                                                void* userdata,
                                                realm_free_userdata_func_t userdata_free) RLM_API_NOEXCEPT;

/**
 * Register a callback that will be invoked when all pending uploads have completed.
 */
RLM_API void realm_sync_session_wait_for_upload_completion(realm_sync_session_t*, realm_sync_upload_completion_func_t,
                                                           void* userdata,
                                                           realm_free_userdata_func_t userdata_free) RLM_API_NOEXCEPT;


#endif // REALM_H
