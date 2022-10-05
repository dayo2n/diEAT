//
//  MainView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI

struct MainView: View {
    
    let user: User
    var body: some View {
        ProfileHeaderView(user: user)
    }
}
