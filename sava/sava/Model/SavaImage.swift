//
//  SavaImage.swift
//  sava
//
//  Created by Mirza Učanbarlić on 28. 1. 2024..
//

import SwiftUI

struct SavaImage: Identifiable, Equatable {
    enum SavaImageError: Error {
        case failedImportingFromURL
        case failedImportingFromData
    }
    
    let id = UUID()
    let width: Int
    let height: Int
    
    #if os(iOS)
    let wrappedImage: UIImage
    var name: String { "nesto" }
    
    init(wrappedImage: UIImage) {
        self.wrappedImage = wrappedImage
        self.width = Int(wrappedImage.size.width)
        self.height = Int(wrappedImage.size.height)
    }
    #elseif os(macOS)
    let url: URL
    var name: String {
        url.lastPathComponent
    }
    init(url: URL) {
        self.url = url
        if let tuple = Self.getDimensions(for: self.url) {
            self.width = tuple.0
            self.height = tuple.1
        } else {
            self.width = 0
            self.height = 0
        }
    }
    
    private static func getDimensions(for url: URL) -> (Int, Int)? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? else {
            return nil
        }
        let w = imageProperties[kCGImagePropertyPixelWidth] as! Int
        let h = imageProperties[kCGImagePropertyPixelHeight] as! Int
        return (w, h)
    }
#endif
}




extension SavaImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        #if os(iOS)
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw SavaImageError.failedImportingFromData
            }
            return SavaImage(wrappedImage: image)
        }
        #elseif os(macOS)
        DataRepresentation(importedContentType: .url) { data in
            guard let url = URL(dataRepresentation: data, relativeTo: nil), url.isImageFile else {
                throw SavaImageError.failedImportingFromURL
            }
            return SavaImage(url: url)
        }
        #endif
    }
}
