//
//  NavigateTo.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 27.04.23.
//

import SwiftUI

struct NavigateTo<Link: View, DetailView: View>: View {
    @State private var isShowingNavigation = false
    
    let link:           Link
    let detailView:     DetailView
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appConfig: AppConfig
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    init(
        @ViewBuilder _ link:            () -> Link,
        @ViewBuilder _ detailView:      () -> DetailView
    ) {
        self.link           = link()
        self.detailView     = detailView()
    }
    
    var body: some View {
        NavigationLink(
            destination: detailViewBody()
                .navigationBarBackButtonHidden(true),
            isActive: $isShowingNavigation,
            label: { link }
        )
    }
    
    @ViewBuilder
    func detailViewBody() -> some View {
        ZStack{
            VStack {
                detailView
            }
            
            VStack{
                HStack(){
                    BackBTN(size: 30, foreground: currentTheme.text, background: currentTheme.textBlack)
                        .onTapGesture {
                            isShowingNavigation = false
                            appConfig.dismissNavigationLink = true
                        }
                    Spacer()
                }
                .ignoresSafeArea()
                Spacer()
            }
            .padding()
        }
    }
}
