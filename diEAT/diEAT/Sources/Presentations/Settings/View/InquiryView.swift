//
//  InquiryView.swift
//  diEAT
//
//  Created by 문다 on 2022/11/23.
//

import SwiftUI

struct InquiryView: View {
    
    @State private var title = ""
    @State private var contents = ""
    @State private var noBlank = false
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel = InquiryViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text(String.cancel)
                        }
                        .padding(10)
                        
                        Spacer()
                        
                        Button {
                            if title.count == 0 || contents.count == 0 {
                                noBlank.toggle()
                            } else {
                                viewModel.uploadInquiry(
                                    title: title,
                                    contents: contents
                                ) { _ in
                                    dismiss()
                                }
                            }
                        } label: {
                            Text(String.complete)
                        }
                        .padding(10)
                        .alert(
                            String.failedToSend,
                            isPresented: $noBlank
                        ) {
                            Button(
                                String.complete,
                                role: .cancel
                            ) {
                                noBlank = false
                            }
                        } message: {
                            Text(String.inquiryGuideMessage)
                        }
                    }
                    
                    CustomTextField(
                        text: $title,
                        placeholder: Text(String.enterTitle),
                        imageName: String.envelopOpenFill
                    )
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .padding(20)
                    .frame(height: 50)
                    .border(Theme.defaultColor(scheme), width: 0.7)
                    .padding([.leading, .trailing])
                    
                    ZStack {
                        VStack {
                            TextField(
                                String.enterContents,
                                text: $contents,
                                axis: .vertical
                            )
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding(20)
                            .border(Theme.defaultColor(scheme), width: 0.7)
                            .padding([.leading, .trailing])
                            Spacer()
                            Text(String.successToSendInquiry)
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.all)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.top)
            .background(Theme.bgColor(scheme))
        }
    }
}
