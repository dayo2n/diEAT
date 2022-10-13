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
    
    var body: some View {
        LazyVGrid(columns: items, content: {
            ForEach(1..<6) { post in
                ZStack {
                    Image("defaultPostImage")
                        .resizable()
                        .frame(width: width - 5, height: width)
                        .scaledToFill()
                    
                    HStack {
                        VStack{
                            Text("Breakfast")
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
        })
    }
}

struct CustomGridView_Previews: PreviewProvider {
    static var previews: some View {
        CustomGridView()
    }
}
