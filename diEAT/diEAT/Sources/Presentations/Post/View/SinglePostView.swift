//
//  SinglePostView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/17.
//

import SwiftUI
import Kingfisher

struct SinglePostView: View {
    
    var post: Post
    @Environment(\.colorScheme) var scheme
    @State var isEditPostMode: Bool = false
    @State var selectedDate: Date
    @ObservedObject var viewModel: FetchPostViewModel
    @Environment(\.dismiss) private var dismiss
    @State var showDeleteAlert: Bool = false
    
    var body: some View {
        if isEditPostMode {
            EditPostView(
                post: post,
                isEditMode: true,
                selectedDate: $selectedDate,
                isShownThisView: $isEditPostMode
            )
        } else {
            VStack {
                KFImage(URL(string: post.imageUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: UIScreen.main.bounds.width - 20,
                        height: UIScreen.main.bounds.width - 20
                    )
                    .cornerRadius(8)
                    .padding()
                
                HStack {
                    Text("# \(Date2OnlyDate(date: post.timestamp.dateValue()))'s ")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .frame(height: 20)
                        .padding(5)
                        .background(Color.black.opacity(0.2))
                    
                    Text("# \(post.mealtime)")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .frame(height: 20)
                        .padding(5)
                        .background(Color.black.opacity(0.2))
                    
                    if let icon = post.icon {
                        HStack {
                            Text(String.hashtag)
                            Image(icon)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .padding(5)
                        .background(Color.black.opacity(0.2))
                    }
                    Spacer()
                }
                .padding([.leading, .bottom])
                
                HStack {
                    Image(systemName: String.highlighter)
                        .font(.system(size: 20))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding(.leading)
                    
                    Text(post.caption)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                Spacer()
            }
            .background(Theme.bgColor(scheme))
            .toolbar {
                Group {
                    Button { isEditPostMode.toggle()
                    } label: {
                        HStack {
                            Image(systemName: String.pencilTip)
                                .foregroundColor(Theme.textColor(scheme))
                        }
                    }
                    .padding(.trailing, 15)
                    Button { 
                        self.showDeleteAlert.toggle()
                    } label: {
                        Image(systemName: String.trash)
                            .foregroundColor(.red)
                    }
                    .alert(
                        String.deleteRecord,
                        isPresented: $showDeleteAlert
                    ) {
                        Button(
                            String.optionCancel,
                            role: .cancel
                        ) {
                            self.showDeleteAlert.toggle()
                        }
                        Button(
                            String.optionDelete,
                            role: .destructive
                        ) {
                            viewModel.deletePost(id: post.id!)
                            dismiss()
                        }
                    } message: {
                        Text(String.deleteMessage)
                    }
                }
            }
        }
    }
}
