//
//  CustomGridView.swift
//  diEAT
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
        LazyVGrid(
            columns: items,
            spacing: 2
        ) {
            ForEach(viewModel.postsByDay) { post in
                NavigationLink(
                    destination: SinglePostView(
                        post: post,
                        selectedDate: post.timestamp.dateValue(),
                        viewModel: viewModel
                    )
                ) {
                    ZStack {
                        KFImage(URL(string: post.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: length, height: length)
                            .cornerRadius(8)
                        
                        RecordLabelView(post: post)
                    }
                    .padding(.bottom, 1)
                }
            }
        }
    }
}
