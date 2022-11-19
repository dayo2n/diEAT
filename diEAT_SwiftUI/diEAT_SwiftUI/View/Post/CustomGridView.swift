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
    private let width = UIScreen.main.bounds.width / 2
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel
    
    var body: some View {
        LazyVGrid(columns: items, content: {
            ForEach(viewModel.posts) { post in
                NavigationLink(destination: SinglePostView(post: post, selectedDate: post.timestamp.dateValue(), viewModel: viewModel)) {
                    ZStack {
                        KFImage(URL(string: post.imageUrl))
                            .resizable()
                            .frame(width: width - 5, height: width)
                            .scaledToFill()
                        
                        HStack {
                            VStack{
                                Text("\(post.mealtime)")
                                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    .foregroundColor(Theme.textColor(scheme))
                                    .padding(5)
                                    .background(Theme.bgColor(scheme).opacity(0.7))
                                    .padding([.leading, .top], 5)
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
