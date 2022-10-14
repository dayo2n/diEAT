//
//  EatLog.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI

struct EatLog: View {
    @State var editPostMode: Bool
    @State var selectedDate: Date
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        VStack {
            // Eat Log

            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.bottom, 3)
                
                Text("\(Date2OnlyDate(date: selectedDate))")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.textColor(scheme))
                
                Image(systemName: "quote.closing")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.top, 3)
                
                Spacer()
                
                Button(action: {
                    editPostMode.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(Theme.textColor(scheme))
                }).sheet(isPresented: $editPostMode, onDismiss: { viewModel.fetchPost(selectedDate: selectedDate) }, content: {
                    NavigationView {
                        EditPostView(editMode: true, editPostMode: $editPostMode, selectedDate: $selectedDate)
                    }
                })
            }
            .padding([.leading, .trailing], 20)
            
            ScrollView {
                CustomGridView(viewModel: viewModel)
            }
        }
    }
}
