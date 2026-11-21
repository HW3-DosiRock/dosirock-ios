//
//  SplashView.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct SplashView: View {

    @State private var showTitle = false

    var body: some View {

        ZStack {
            Color("LaunchBackground").ignoresSafeArea()

            VStack {
                
                Image(.launchLogo)  // 시스템 화면과 같은 위치·크기
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                
                VStack{
                Text("splash_title")
                    .appFont(.brandTitle)
                    .foregroundStyle(Color.appTextPrimary)
                    
                Text("splash_subtitle")
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                    
                Text("splash_tagline")
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextPrimary)
                }
                .opacity(showTitle ? 1 : 0)  // 로고 아래 글자만 나타나게
                    
                
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) { showTitle = true }
            }
        }
    }
}

#Preview {
    SplashView()
}
