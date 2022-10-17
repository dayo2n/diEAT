//
//  SinglePostView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/17.
//

import SwiftUI
import Kingfisher

struct SinglePostView: View {
    
    let post: Post
    @Environment(\.colorScheme) var scheme
    var body: some View {
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
            }.padding(.leading)
            
            HStack {
                Image(systemName: "pencil")
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
        }.background(Theme.bgColor(scheme))
    }
}
