#if os(iOS)
import UIKit
public typealias Image = UIImage
#elseif os(macOS)
import AppKit
public typealias Image = NSImage
#endif
import CoreTransferable

public enum SwiftImgResizeError: LocalizedError {
    case couldNotReadImageFromURL
    case couldNotGetPNGDataFromImage
    case couldNotLoadImageFromData
    case failedResizingImage
}

public struct ResizedImage: Transferable {
    public let wrappedImage: Image
    
    public var data: Data? {
        #if os(iOS)
        wrappedImage.pngData()
        #elseif os(macOS)
        wrappedImage.tiffRepresentation
        #endif
    }
    
    public init(wrappedImage: Image) {
        self.wrappedImage = wrappedImage
    }
    
    public init(data: Data) throws {
        guard let img = Image(data: data) else {
            throw SwiftImgResizeError.couldNotLoadImageFromData
        }
        self.wrappedImage = img
    }
    
    public static var transferRepresentation: some TransferRepresentation {
        #if os(iOS)
        DataRepresentation(contentType: .png) {  image in
            guard let data = image.wrappedImage.pngData() else {
                throw SwiftImgResizeError.couldNotGetPNGDataFromImage
            }
            return data
           
        } importing: { data in
            guard let image = Image(data: data) else {
                throw SwiftImgResizeError.couldNotLoadImageFromData
            }
            return ResizedImage(wrappedImage: image)
        }
        #elseif os(macOS)
        DataRepresentation(contentType: .png) {  image in
            let imageRep = NSBitmapImageRep(data: image.wrappedImage.tiffRepresentation!)
            guard let data = imageRep?.representation(using: .png, properties: [:]) else {
                throw SwiftImgResizeError.couldNotLoadImageFromData
            }
            return data
           
        } importing: { data in
            guard let image = Image(data: data) else {
                throw SwiftImgResizeError.couldNotLoadImageFromData
            }
            return ResizedImage(wrappedImage: image)
        }
        #endif
    }
}

public func resize(imageURL: URL, width: CGFloat, height: CGFloat) throws -> ResizedImage {
    let image = try loadImage(from: imageURL)
    return try resize(image: image, width: width, height: height)
}

public func resize(image: Image, width: CGFloat, height: CGFloat) throws -> ResizedImage {
    #if os(iOS)
    let size = CGSizeMake(width, height)
    let renderer = UIGraphicsImageRenderer(size: size)
    let newImage = renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
    #elseif os(macOS)
    guard let imageData = image.tiffRepresentation,
          let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
          let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
        throw SwiftImgResizeError.couldNotReadImageFromURL
    }
    
    let context = CGContext(data: nil,
                            width: Int(width),
                            height: Int(height),
                            bitsPerComponent: image.bitsPerComponent,
                            bytesPerRow: 0,
                            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: image.bitmapInfo.rawValue)
    context?.interpolationQuality = .high
    let size = CGSize(width: width, height: height)
    context?.draw(image, in: CGRect(origin: .zero, size: size))
    guard let scaledImage = context?.makeImage() else {
        throw SwiftImgResizeError.failedResizingImage
    }
    let newImage = Image(cgImage: scaledImage, size: size)
    #endif
    return ResizedImage(wrappedImage: newImage)
}

private func loadImage(from url: URL) throws -> Image {
    #if os(iOS)
    guard let image = Image(contentsOfFile: url.absoluteString) else {
        throw SwiftImgResizeError.couldNotReadImageFromURL
    }
    return image
    #elseif os(macOS)
    guard let image = Image(contentsOf: url) else {
        throw SwiftImgResizeError.couldNotReadImageFromURL
    }
    return image
    #endif
}
