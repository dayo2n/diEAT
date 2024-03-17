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
                            "작성 실패",
                            isPresented: $noBlank
                        ) {
                            Button(
                                String.complete,
                                role: .cancel
                            ) {
                                noBlank = false
                            }
                        } message: {
                            Text("제목 또는 내용을 입력해야 합니다.")
                        }
                    }
                    
                    CustomTextField(
                        text: $title,
                        placeholder: Text("제목을 입력하세요"),
                        imageName: "envelope.open.fill"
                    )
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .padding(20)
                    .frame(height: 50)
                    .border(Theme.defaultColor(scheme), width: 0.7)
                    .padding([.leading, .trailing])
                    
                    ZStack {
                        VStack {
                            if #available(iOS 16.0, *) {
                                TextField(
                                    "개발팀에 전달할 내용을 입력하세요",
                                    text: $contents,
                                    axis: .vertical
                                )
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(20)
                                .border(Theme.defaultColor(scheme), width: 0.7)
                                .padding([.leading, .trailing])
                            } else {
                                // Fallback on earlier versions
                            }
                            Spacer()
                            
                            Text("작성하신 내용은 검토 후 등록하신 계정의 이메일로 결과를 전달해 드리겠습니다. 감사합니다 :))")
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
