//
//  DailyEatLog.swift
//  diEAT
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI

struct DailyEatLog: View {
    @State var isEditPostMode = false
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            // Eat Log
            HStack {
                Image(systemName: .quoteOpening)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(colorScheme))
                    .padding(.bottom, 3)
                
                Text(selectedDate.utc2kst.date2OnlyDate)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.textColor(colorScheme))
                
                Image(systemName: .quoteClosing)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(colorScheme))
                    .padding(.top, 3)
                
                Spacer()
                
                Button {
                    self.isEditPostMode.toggle()
                } label: {
                    Image(systemName: .plus)
                        .padding(2)
                }
                .buttonStyle(BorderedButtonStyle())
                .fullScreenCover(isPresented: $isEditPostMode) {
                    viewModel.fetchPostByDate(selectedDate: selectedDate)
                } content: {
                    EditPostView(
                        isEditMode: false,
                        selectedDate: $selectedDate,
                        isShownThisView: $isEditPostMode
                    )
                }
            }
            .padding([.leading, .trailing], 10)
            CustomGridView(viewModel: viewModel)
        }
    }
}
