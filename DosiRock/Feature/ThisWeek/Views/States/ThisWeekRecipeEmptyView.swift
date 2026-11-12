//
//  ThisWeekRecipeEmptyView.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

struct ThisWeekRecipeEmptyView: View {
    var body: some View {
        VStack{
            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                .padding(.bottom, Spacing.xs)

            Text("thisweek_empty_desc")
                .appFont(.brandSubtitle)
                .multilineTextAlignment(.center)  // 여러 줄일 때 가운데 정렬
        }
        .frame(maxWidth: .infinity , maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    ThisWeekRecipeEmptyView()
}
