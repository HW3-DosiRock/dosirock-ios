//
//  TabMainHeader.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct TabMainHeader: View {
    
    let title : String
    
    var body: some View {
        
        HStack(){
            Text(title)
                .frame(maxWidth: .infinity , alignment: .leading)
                .appFont(.brandTitle)
        }
        .padding(Spacing.screenHorizontal)
    }
}

#Preview {
    VStack{
        TabMainHeader(title: "냉장고")
        TabMainHeader(title: "이번주")
        TabMainHeader(title: "마이페이지")
    }
}
