//
//  String+.swift
//  diEAT
//
//  Created by 제나 on 3/17/24.
//

import Foundation

extension String {
    /* Images */
    static let defaultProfileImage = "defaultProfileImg"
    static let backgroundImageDark = "backgroundImageDark"
}

extension String {
    /* SF Symbols */
    static let plus = "plus"
    static let lock = "lock"
    static let trash = "trash"
    static let pencil = "pencil"
    static let envelope = "envelope"
    static let key = "key"
    static let keyFill = "key.fill"
    static let person = "person"
    static let personFill = "person.fill"
    static let chevronLeft = "chevron.left"
    static let chevronRight = "chevron.right"
    static let quoteOpening = "quote.opening"
    static let quoteClosing = "quote.closing"
    static let highlighter = "highlighter"
    static let pencilTip = "pencil.tip"
    static let listBullet = "list.bullet"
    static let squareGrid2x2 = "square.grid.2x2"
    static let squareAndArrowUp = "square.and.arrow.up"
    static let personCropCircleFillBadgeXmark = "person.crop.circle.fill.badge.xmark"
    
    /* Strings */
    static let hashtag = "#"
    static let today = "TODAY"
    
    /* App */
    static let app = "diEAT"
    
    /* Login View */
    static let login = "LOGIN"
    static let signIn = "Sign in"
    static let email = "EMAIL"
    static let password = "PASSWORD"
    static let ifHasNoAuth = "계정이 없다면"
    static let registration = "회원가입"
    static let ifForgotPassword = "비밀번호를 잊어버렸다면"
    static let inputEmailToResetPassword = "비밀번호를 재설정할 이메일 입력"
    static let sendResetEmail = "재설정 메일 전송"
    /// alert
    static let optionCheck = "확인"
    static let successToSend = "전송 성공"
    static let checkEmailBoxMessage = "수신한 이메일을 통해 비밀번호를 재설정하세요. 이메일이 도착하지 않으면 스팸메일함을 확인하세요."
    
    // Registration View
    static let signUp = "Sign up"
    static let username = "USERNAME"
    static let ifAlreadyHaveAccount = "Already have an account?"
    
    // Edit Profile View
    static let editText = "편집"
    static let complete = "완료"
    static let changePassword = "비밀번호 재설정"
    /// alert
    static let withdrawal = "회원 탈퇴"
    static let optionWithdrawal = "탈퇴"
    static let withdrawalCautionMessage = "탈퇴 후 데이터를 복원할 수 없습니다."
    
    // Edit Post View
    /// buttons
    static let add = "Add"
    static let edit = "Edit"
    static let cancel = "Cancel"
    static let selectImage = "Select image"
    
    /// Text
    static let mealHeader = "# 식사"
    static let recordHeader = "# 기록"
    static let stickerHeader = "# 스티커"
    static let captionPlaceholder = "스스로 피드백을 남기는 공간"
    
    // Single Post View
    /// alert
    static let deleteRecord = "기록 삭제"
    static let optionCancel = "취소"
    static let optionDelete = "삭제"
    static let deleteMessage = "기록을 삭제하면 되돌릴 수 없습니다."
    
    /* popup */
    static let alertPutAllAuthInformation = "로그인 정보를 모두 입력하세요!"
    static let alertWrongInput = "아이디 또는 비밀번호를 확인하세요."
    static let alertFailedToUpload = "업로드 실패!\n 식단 이미지를 첨부해 주세요 :("
    static let alertErrorOccured = "오류가 발생했습니다"
    static let alertFillAllBlank = "항목을 모두 작성하세요!"
    static let alertAlreadyRegistered = "이미 가입되어 있는 이메일입니다."
    static let alertInvaildEmail = "이메일 형식이 올바르지 않습니다."
    static let alertPasswordCountBiggerThan6 = "비밀번호를 6자리 이상 입력하세요."
}
