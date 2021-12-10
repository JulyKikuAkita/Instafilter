//
//  InstafilterApp.swift
//  Instafilter
//
//  Created by Ifang Lee on 12/7/21.
//

import SwiftUI

@main
struct InstafilterApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 15.0, *) {
                ContentView()
            } else {
                Text("Not supporrt iOS version")
            }
        }
    }
}
