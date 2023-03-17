//
//  EatLog.swift
//  diEAT
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI

struct EatLog: View {
    @State var isEditPostMode: Bool = false
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            // Eat Log
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.bottom, 3)
                
                Text("\(Date2OnlyDate(date: UTC2KST(date: selectedDate)))")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.textColor(scheme))
                
                Image(systemName: "quote.closing")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.top, 3)
                
                Spacer()
                
                Button(action: {
                    isEditPostMode.toggle()
                }, label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 35, height: 35)
                            .cornerRadius(8)
                            .foregroundColor(Theme.btnColor(scheme))
                            .opacity(0.7)
                        
                        Image(systemName: "plus")
                            .foregroundColor(Theme.textColor(scheme))
                    }
                    .frame(width: 44, height: 44)
                }).fullScreenCover(isPresented: $isEditPostMode) {
                    viewModel.fetchPost(selectedDate: selectedDate)
                } content: {
                    NavigationView {
                        EditPostView(isEditMode: false, selectedDate: $selectedDate)
                    }
                }
            }
            .padding([.leading, .trailing], 10)
            
            ScrollView {
                CustomGridView(viewModel: viewModel)
            }
        }
    }
}
