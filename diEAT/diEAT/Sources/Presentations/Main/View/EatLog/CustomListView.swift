//
//  CustomListView.swift
//  diEAT
//
//  Created by 제나 on 3/12/24.
//

import SwiftUI
import Kingfisher

struct CustomListView: View {
    private let length = UIScreen.main.bounds.width / 3
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.postsByMonth) { post in
                NavigationLink(
                    destination: SinglePostView(
                        post: post,
                        selectedDate: post.timestamp.dateValue(),
                        viewModel: viewModel
                    )
                ) {
                    VStack {
                        let postDate = Date2OnlyDate(date: post.timestamp.dateValue())
                        HStack {
                            Image(systemName: String.quoteOpening)
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textColor(colorScheme))
                                .padding(.bottom, 3)
                            Text(postDate)
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.textColor(colorScheme))
                            Image(systemName: String.quoteClosing)
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textColor(colorScheme))
                                .padding(.top, 3)
                            Spacer()
                        }
                        .padding(.top)
                        HStack {
                            KFImage(URL(string: post.imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: length, height: length)
                                .cornerRadius(8)
                            VStack {
                                HStack {
                                    Text("# \(post.mealtime)")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundStyle(Theme.textColor(colorScheme))
                                        .frame(height: 20)
                                        .padding(2)
                                        .background(Theme.bgColor(colorScheme).opacity(0.7))
                                        .padding([.leading, .top], 5)
                                    if let icon = post.icon {
                                        HStack {
                                            Text("#")
                                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                                .foregroundStyle(Theme.textColor(colorScheme))
                                            Image(icon)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                        .padding(2)
                                        .background(Theme.bgColor(colorScheme).opacity(post.icon == nil ? 0.0 : 0.7))
                                        .padding(.top, 5)
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Text(post.caption)
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundStyle(Theme.textColor(colorScheme))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.bottom, 1)
                    }
                }
            }
        }
    }
}
