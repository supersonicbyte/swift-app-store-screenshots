//
//  OutputSize.swift
//  sava
//
//  Created by Mirza Učanbarlić on 28. 1. 2024..
//

import Foundation

struct OutputSize: Identifiable, Hashable {
    let id = UUID()
    let width: Int
    let height: Int
    let name: String
    let description: String
    let isImportant: Bool
    let systemIconName: String
    
    init(width: Int, height: Int, name: String, description: String, isImportant: Bool = false, systemIconName: String = "iphone") {
        self.height = height
        self.width = width
        self.name = name
        self.description = description
        self.isImportant = isImportant
        self.systemIconName = systemIconName
    }
}

extension OutputSize: CaseIterable {
    static let iPhone67 = OutputSize(
        width: 1290,
        height: 2796,
        name: "iPhone 6.7\"",
        description: "Required if app runs on iPhone and 6.5-inch screenshots aren't provided",
        isImportant: true
    )
    static let iPhone65 = OutputSize(
        width: 1284,
        height: 2778,
        name: "iPhone 6.5\"",
        description: "Required if app runs on iPhone and 6.7-inch screenshots aren't provided",
        isImportant: true
    )
    static let iPhone61 = OutputSize(
        width: 1179,
        height: 2556,
        name: "iPhone 6.1\"",
        description: "Required if app runs on iPhone and 6.5 inch or 6.7-inch screenshots aren't provided"
    )
    static let iPhone58 = OutputSize(
        width: 1170,
        height: 2532,
        name: "iPhone 5.8\"",
        description: "Required if app runs on iPhone and 6.5 inch or 6.7-inch screenshots aren't provided"
    )
    static let iPhone55 = OutputSize(
        width: 1242,
        height: 2208,
        name: "iPhone 5.5\"",
        description: "Required if app runs on iPhone",
        isImportant: true
    )
    static let iPhone47 = OutputSize(
        width: 750,
        height: 1334,
        name: "iPhone 4.7\"",
        description: "Required if app runs on iPhone and 5.5-inch screenshots aren't provided"
    )
    static let iPhone4  = OutputSize(
        width: 640,
        height: 1096,
        name: "iPhone 4\"",
        description: "Required if app runs on iPhone and 5.5 or 4.7-inch screenshots aren't provided"
    )
    static let iPhone35 = OutputSize(
        width: 640,
        height: 920,
        name: "iPhone 4.5\"",
        description: "Required if app runs on iPhone and 5.5-inch iPhone screenshots aren't provided"
    )
    
    static let mac1024x1024 = OutputSize(
        width: 1024,
        height: 1024,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac512x512 = OutputSize(
        width: 512,
        height: 512,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac256x256 = OutputSize(
        width: 256,
        height: 256,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac128x128 = OutputSize(
        width: 128,
        height: 128,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac64x64 = OutputSize(
        width: 64,
        height: 64,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac32x32 = OutputSize(
        width: 32,
        height: 32,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static let mac16x16 = OutputSize(
        width: 16,
        height: 16,
        name: "macOS App Icon",
        description: "",
        systemIconName: "macbook"
    )
    
    static var allCases: [OutputSize] = [
        iPhone35,
        iPhone4,
        iPhone47,
        iPhone55,
        iPhone58,
        iPhone61,
        iPhone65,
        iPhone67,
        mac1024x1024,
        mac512x512,
        mac256x256,
        mac128x128,
        mac64x64,
        mac32x32,
        mac16x16
    ]
}
