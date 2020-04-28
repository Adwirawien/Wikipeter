//
//  SearchResultRow.swift
//  Wikipeter
//
//  Created by Adrian Böhme on 28.04.20.
//  Copyright © 2020 Adrian Böhme. All rights reserved.
//

import SwiftUI

struct SearchResultRow: View {
    let result: Result;
    @State var isOpen = false;
    
    var body: some View {
        Button(action: {self.isOpen = true}) {
            HStack {
            Text(result.title)
                .fontWeight(.bold)
                .font(.system(.body, design: .rounded))
            Spacer()
            Text("\(Double(result.dist).removeZerosFromEnd())m")
            }
        }.padding(12).sheet(isPresented: $isOpen, content: {
            Text("test")
        })
    }
}
