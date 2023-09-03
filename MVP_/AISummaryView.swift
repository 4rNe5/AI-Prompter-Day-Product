//
//  AISummaryView.swift
//  MVP_
//
//  Created by 4rNe5 on 2023/09/03.
//

import SwiftUI

struct AISummaryView: View {
    @Binding var recognizedText: String

    var body: some View {
        Text(recognizedText)
    }
}
