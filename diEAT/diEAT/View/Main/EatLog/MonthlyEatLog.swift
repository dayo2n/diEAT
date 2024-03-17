//
//  MonthlyEatLog.swift
//  diEAT
//
//  Created by 제나 on 3/12/24.
//

import SwiftUI

struct MonthlyEatLog: View {
    @Binding var selectedDate: Date
    @State var isEditPostMode: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FetchPostViewModel
    var body: some View {
        VStack {
            CustomListView(viewModel: viewModel)
            Spacer()
                .frame(height: 100)
        }
        .padding()
    }
}
