//
//  ContentView.swift
//  Instafilter
//
//  Created by Ifang Lee on 12/7/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
    @State private var blurAmount = 0.0 {
        didSet { // won't trigger by slider
            print("Never show \(blurAmount)")
        }
    }

    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white

    var body: some View {
        VStack {
            Circle()
                .foregroundColor(.green)
                .blur(radius: blurAmount)
                .frame(width: 300, height: 300)
                .background(backgroundColor)
                .onTapGesture {
                    showingConfirmation = true
                }
                .confirmationDialog("Change backgroud", isPresented: $showingConfirmation) {
                    Button("Red") {backgroundColor = .red}
                    Button("Blue") {backgroundColor = .blue}
                    Button("Orange") {backgroundColor = .orange}
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Select a new color")
                }

            Slider(value: $blurAmount, in: 0...10)

            Button("Random Blue") {
                blurAmount = Double.random(in: 0...20)
            }
        }
        .onChange(of: blurAmount) { newValue in
            print("New value is \(newValue)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
        } else {
            Text("iOS 14.0")
        }
    }
}
