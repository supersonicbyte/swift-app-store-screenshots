//
//  AppError.swift
//  sava
//
//  Created by Mirza Učanbarlić on 1. 2. 2024..
//

import Foundation

struct AppError: LocalizedError, Equatable {
    let title: String
    let message: String
    
    var errorDescription: String? { message }
    
    init(title: String = "Error", message: String) {
        self.title = title
        self.message = message
    }
}

extension AppError {
    static let unexpected = AppError(message: "Oops, unexpected error occured! Please try again.")
    static let outputSizeMustBeSelected = AppError(message: "Output size must be selected!")
    static let exporting = AppError(message: "Error exporting!")
    static let importing = AppError(message: "Error importing!")
    static let resizing = AppError(message: "Error resizing!")
}
