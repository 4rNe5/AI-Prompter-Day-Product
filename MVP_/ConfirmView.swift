//
//  ConfirmView.swift
//  MVP_
//
//  Created by 4rNe5 on 2023/09/03.
//

import SwiftUI

struct ConfirmView: View {
    @Binding var recognizedText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Scanned text:")
                .font(.headline)
            
            TextArea(text: $recognizedText, placeholder: "")
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
            
            Spacer()
        }
        .padding()
    }
}


struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView(recognizedText:"")
    }
}
