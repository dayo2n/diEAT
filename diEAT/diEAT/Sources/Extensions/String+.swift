//
//  String+.swift
//  diEAT
//
//  Created by 제나 on 3/17/24.
//

import Foundation

// MARK: - Localization Methods
extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
}

extension String {
    /* Images */
    static let octocat = "octocat"
    static let defaultProfileImage = "defaultProfileImg"
    static let backgroundImageDark = "backgroundImageDark"
    static let launchScreenImage = "launchScreenImage"
    static let launchScreenImageDark = "launchScreenImageDark"
}

extension String {
    /* SF Symbols */
    static let key = "key"
    static let plus = "plus"
    static let lock = "lock"
    static let trash = "trash"
    static let pencil = "pencil"
    static let person = "person"
    static let keyFill = "key.fill"
    static let envelope = "envelope"
    static let macwindow = "macwindow"
    static let pencilTip = "pencil.tip"
    static let listBullet = "list.bullet"
    static let personFill = "person.fill"
    static let highlighter = "highlighter"
    static let chevronLeft = "chevron.left"
    static let chevronRight = "chevron.right"
    static let quoteOpening = "quote.opening"
    static let quoteClosing = "quote.closing"
    static let squareGrid2x2 = "square.grid.2x2"
    static let envelopOpenFill = "envelope.open.fill"
    static let squareAndArrowUp = "square.and.arrow.up"
    static let personFillViewfinder = "person.fill.viewfinder"
    static let rectanglePortraitAndArrowRight = "rectangle.portrait.and.arrow.right"
    static let personCropCircleFillBadgeXmark = "person.crop.circle.fill.badge.xmark"
    static let rectanglePortraitAndArrowRightFill = "rectangle.portrait.and.arrow.right.fill"
    
    /* Strings */
    static let hashtag = "hashtag".localized()
    static let today = "today".localized()
    
    /* App */
    static let app = "app".localized()
    
    /* Login View */
    static let login = "login".localized()
    static let signIn = "signIn".localized()
    static let email = "email".localized()
    static let password = "password".localized()
    static let ifHasNoAuth = "ifHasNoAuth".localized()
    static let registration = "registration".localized()
    static let ifForgotPassword = "ifForgotPassword".localized()
    static let inputEmailToResetPassword = "inputEmailToResetPassword".localized()
    static let sendResetEmail = "sendResetEmail".localized()
    /// alert
    static let optionCheck = "optionCheck".localized()
    static let successToSend = "successToSend".localized()
    static let checkEmailBoxMessage = "checkEmailBoxMessage".localized()
    
    // Registration View
    static let signUp = "signUp".localized()
    static let username = "username".localized()
    static let ifAlreadyHaveAccount = "ifAlreadyHaveAccount".localized()
    
    // Main View
    static let welcomeMessage = "welcomeMessage".localized()
    static let days = [
        "sunday".localized(),
        "monday".localized(),
        "tuesday".localized(),
        "wednesday".localized(),
        "thursday".localized(),
        "friday".localized(),
        "saturday".localized()
    ]
    
    // Edit Profile View
    static let editText = "editText".localized()
    static let complete = "complete".localized()
    static let changePassword = "changePassword".localized()
    /// alert
    static let withdrawal = "withdrawal".localized()
    static let optionWithdrawal = "optionWithdrawal".localized()
    static let withdrawalCautionMessage = "withdrawalCautionMessage".localized()
    
    // Edit Post View
    /// buttons
    static let add = "add".localized()
    static let edit = "edit".localized()
    static let cancel = "cancel".localized()
    static let selectImage = "selectImage".localized()
    
    /// Text
    static let mealHeader = "mealHeader".localized()
    static let recordHeader = "recordHeader".localized()
    static let stickerHeader = "stickerHeader".localized()
    static let captionPlaceholder = "captionPlaceholder".localized()
    
    // Single Post View
    /// alert
    static let deleteRecord = "deleteRecord".localized()
    static let optionCancel = "optionCancel".localized()
    static let optionDelete = "optionDelete".localized()
    static let deleteMessage = "deleteMessage".localized()
    
    // Inquiry View
    static let failedToSend = "failedToSend".localized()
    static let inquiryGuideMessage = "inquiryGuideMessage".localized()
    static let enterTitle = "enterTitle".localized()
    static let enterContents = "enterContents".localized()
    static let successToSendInquiry = "successToSendInquiry".localized()
    
    // Settings View
    static let editUserInformation = "editUserInformation".localized()
    static let signOut = "signOut".localized()
    static let inquiryOrBugReport = "inquiryOrBugReport".localized()
    static let githubId = "Github @dayo2n"
    static let githubUrl = "https://github.com/dayo2n"
    
    /* popup */
    static let alertPutAllAuthInformation = "alertPutAllAuthInformation".localized()
    static let alertWrongInput = "alertWrongInput".localized()
    static let alertFailedToUpload = "alertFailedToUpload".localized()
    static let alertErrorOccurred = "alertErrorOccurred".localized()
    static let alertFillAllBlank = "alertFillAllBlank".localized()
    static let alertAlreadyRegistered = "alertAlreadyRegistered".localized()
    static let alertInvaildEmail = "alertInvaildEmail".localized()
    static let alertPasswordCountBiggerThan6 = "alertPasswordCountBiggerThan6".localized()
}
