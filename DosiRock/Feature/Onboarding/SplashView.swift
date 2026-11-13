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
                
                Image("launch-logo")  // 시스템 화면과 같은 위치·크기
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                
                VStack{
                Text("도시의 돌멩이")
                    .appFont(.brandTitle)
                    .foregroundStyle(Color.appTextPrimary)
                    
                Text("도시락 : 하루를 살아가는 도시의 돌멩이")
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                    
                Text("직장인을 위한 도시락 준비·절약 기록")
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
