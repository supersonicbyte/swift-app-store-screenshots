//
//  SwiftImgResize+Sava.swift
//  sava
//
//  Created by Mirza Učanbarlić on 28. 1. 2024..
//

import SwiftUI
import SwiftImgResize
import UniformTypeIdentifiers

extension ResizedImage: FileDocument {
    enum FileDocumentError: Error {
        case errorRetrievingDataFromImage
    }
    
    public static var readableContentTypes: [UTType] = [.image, .jpeg, .png]
    
    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try ResizedImage(data: data)
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = self.data else {
            throw FileDocumentError.errorRetrievingDataFromImage
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
