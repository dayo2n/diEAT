//
//  CustomGridView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/12.
//

import SwiftUI
import Kingfisher

struct CustomGridView: View {
    
    private let items = [GridItem(), GridItem()]
    private let length = UIScreen.main.bounds.width / 2
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        LazyVGrid(columns: items, spacing: 2, content: {
            ForEach(viewModel.posts) { post in
                NavigationLink(destination: SinglePostView(post: post, selectedDate: post.timestamp.dateValue(), viewModel: viewModel)) {
                    ZStack {
                        KFImage(URL(string: post.imageUrl))
                            .resizable()
                            .frame(width: length, height: length)
                            .scaledToFill()
                            .cornerRadius(10)
                        
                        HStack {
                            VStack{
                                HStack {
                                    Text("# \(post.mealtime)")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(Theme.textColor(scheme))
                                        .frame(height: 20)
                                        .padding(5)
                                        .background(Theme.bgColor(scheme).opacity(0.7))
                                        .padding([.leading, .top], 5)
                                    HStack {
                                        Text("#")
                                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                                            .foregroundColor(Theme.textColor(scheme))
                                        Image("\(post.icon)")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(5)
                                    .background(Theme.bgColor(scheme).opacity(0.7))
                                    .padding(.top, 5)
                                }
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom, 1)
                }
            }
        })
    }
}
