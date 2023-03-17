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
            EditPostView(post: post, isEditMode: true, selectedDate: $selectedDate)
        } else {
            VStack {
                KFImage(URL(string: post.imageUrl))
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .scaledToFit()
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
                    
                    HStack {
                        Text("\(post.icon == nil ? "" : "#")")
                        Image("\(post.icon ?? "")")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(5)
                    .background(Color.black.opacity(post.icon == nil ? 0.0 : 0.2))
                    
                    Spacer()
                }.padding([.leading, .bottom])
                
                HStack {
                    Image(systemName: "highlighter")
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
                    Button(action: { isEditPostMode.toggle() }, label: {
                        HStack {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(Theme.textColor(scheme))
                        }
                    })
                    .padding(.trailing, 15)
                    Button(action: { self.showDeleteAlert.toggle()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                    .alert("기록 삭제", isPresented: $showDeleteAlert) {
                        Button("취소", role: .cancel, action: { self.showDeleteAlert.toggle() })
                        Button("삭제", role: .destructive, action: {
                            viewModel.deletePost(id: post.id!)
                            dismiss()
                        })
                    } message: {
                        Text("기록을 삭제하면 되돌릴 수 없습니다.")
                    }
                }
            }
        }
    }
}
