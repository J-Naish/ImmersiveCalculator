//
//  ImmersiveCalculatorApp.swift
//  ImmersiveCalculator
//
//  Created by 西凜太朗 on 2023/08/01.
//

import SwiftUI

@main
struct ImmersiveCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
