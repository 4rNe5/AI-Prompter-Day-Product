//
//  TextAreaCode.swift
//  MVP_
//
//  Created by 4rNe5 on 2023/09/03.
//

import SwiftUI

struct TextArea: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var maxLength: Int = 100

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.text = placeholder
        myTextView.textColor = UIColor.gray

        myTextView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.textColor == UIColor.gray && text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.gray
        } else {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextArea

        init(_ uiTextView: TextArea) {
            self.parent = uiTextView
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.gray {
                textView.text = nil
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.gray
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            let nonWhitespaceCharCount = updatedText.unicodeScalars.filter { !CharacterSet.whitespacesAndNewlines.contains($0) }.count
            return nonWhitespaceCharCount <= parent.maxLength
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}
