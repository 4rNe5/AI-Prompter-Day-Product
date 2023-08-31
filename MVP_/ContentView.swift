//
//  ContentView.swift
//  MVP_
//
//  Created by 4rNe5 on 2023/08/27.
//

import SwiftUI

struct ContentView: View {

    @State var idText: String = ""

    @State var pwText: String = ""

    var body: some View {

        VStack {

            Image(systemName: "rectangle.on.rectangle.circle")
                .resizable()
                .frame(width: 150, height: 150)
                .foregroundColor(.black.opacity(0.85))
            
            Text("노트정리를 바꾸다.")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black.opacity(0.85))
            
            Text("\(Text("N/O").foregroundColor(Color.purple))Write")
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.black.opacity(0.85))
                .padding(.bottom,40)
            HStack {

                Image(systemName: "exclamationmark.lock.fill")
                    .padding(.leading, 10)

                TextField("ID", text: $idText)
                    .bold()
            }
            .frame(width: 600, height: 60)
            .background(.gray.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(5)

            HStack {

                Image(systemName: "exclamationmark.lock.fill")
                    .padding(.leading, 10)

                SecureField("PW", text: $pwText)
                    .bold()
            }
            .frame(width: 600, height: 60)
            .background(.gray.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal, 20)

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

