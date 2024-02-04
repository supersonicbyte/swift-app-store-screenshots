//
//  savaApp.swift
//  sava
//
//  Created by Mirza Učanbarlić on 23. 1. 2024..
//

import SwiftUI

@main
struct savaApp: App {
    @State private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(appViewModel)
    }
}
