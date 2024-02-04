//
//  URL+sava.swift
//  sava
//
//  Created by Mirza Učanbarlić on 1. 2. 2024..
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    var isImageFile: Bool {
        UTType(filenameExtension: pathExtension)?.conforms(to: .image) ?? false
    }
}
