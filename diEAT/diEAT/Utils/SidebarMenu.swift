//
//  SidebarMenu.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/11/19.
//

import Foundation
import SwiftUI

struct SidebarMenu<SidebarContent: View, Content: View>: View {
    
    let sidebarContent: SidebarContent
    let mainContent: Content
    let sidebarWidth: CGFloat
    @Binding var showSidebar: Bool
    
    init(sidebarWidth: CGFloat, showSidebar: Binding<Bool>, @ViewBuilder sidebar: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self.sidebarWidth = sidebarWidth
        self._showSidebar = showSidebar
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            sidebarContent
                .frame(width: sidebarWidth, alignment: .center)
                .offset(x: showSidebar ? 0 : -1 * sidebarWidth, y: 0)
                .animation(Animation.easeInOut.speed(2))
            mainContent
                .overlay(
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(showSidebar ? 0.02 : 0)
                                .onTapGesture {
                                    self.showSidebar = false
                                }
                        } else {
                            Color.clear
                            .opacity(showSidebar ? 0 : 0)
                            .onTapGesture {
                                self.showSidebar = false
                            }
                        }
                    }
                )
                .offset(x: showSidebar ? sidebarWidth : 0, y: 0)
                .animation(Animation.easeInOut.speed(2))
                
        }
    }
}

// ref. https://gist.github.com/BetterProgramming/20536c74735ba03ebeb1a06a1050ede7#file-sidebarstack-swift

/*
 Use example
 struct ContentView: View {
     
     // Controls display of sidebar
     @State var showSidebar: Bool = false
     
     var body: some View {
         SidebarMenu(sidebarWidth: 125, showSidebar: $showSidebar) {
            // Sidebar content here
         } content: {
            // Main content here
         }.edgesIgnoringSafeArea(.all)
     }
 }
 */
