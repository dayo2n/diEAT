//
//  SinglePostView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/17.
//

import SwiftUI
import Kingfisher

struct SinglePostView: View {
    
    var post: Post
    @Environment(\.colorScheme) var scheme
    @State var editPostMode: Bool = false
    @State var selectedDate: Date
    @ObservedObject var viewModel: FetchPostViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if editPostMode {
            EditPostView(post: post, editMode: true, selectedDate: $selectedDate)
        } else {
            VStack {
                KFImage(URL(string: post.imageUrl))
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .scaledToFit()
                    .padding()

                HStack {
                    HStack {
                        Text("\(Date2OnlyDate(date: post.timestamp.dateValue()))'s ")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            
                        Text(post.mealtime)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                    }
                    .padding(5)
                    .background(Color.black.opacity(0.2))
                    
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
                        .padding(.leading)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                Spacer()
            }
            .background(Theme.bgColor(scheme))
            .toolbar {
                Group {
                    Button(action: { editPostMode.toggle() }, label: {
                        HStack {
                            Image(systemName: "pencil.tip")
                                .foregroundColor(Theme.textColor(scheme))
                        }
                    })
                    Button(action: {
                        viewModel.deletePost(id: post.id!)
                        dismiss()
                        
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                }
            }
        }
    }
}
