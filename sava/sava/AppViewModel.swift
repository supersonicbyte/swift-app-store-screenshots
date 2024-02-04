//
//  AppViewModel.swift
//  sava
//
//  Created by Mirza Učanbarlić on 23. 1. 2024..
//

import Foundation
import Observation
import SwiftImgResize
import CoreTransferable
import SwiftUI
import PhotosUI

@Observable
final class AppViewModel {
    enum Error: LocalizedError {
        case failedResizing
        
        var errorDescription: String? {
            switch self {
            case .failedResizing:
                return "Failed resizing!"
            }
        }
    }
    enum State {
        case idle
        case selected
        case resized
    }
    private(set) var state = State.idle
    private(set) var selectedImages: [SavaImage] = []
    private(set) var resizedImages: [ResizedImage] = []
    
    #if os(iOS)
    func setSelectedImages(images: [PhotosPickerItem]) {
        Task {
            var imgs: [SavaImage] = []
            for item in images {
                guard let image = try await item.loadTransferable(type: SavaImage.self) else {
                    continue
                }
                imgs.append(image)
            }
            self.selectedImages = imgs
            self.state = .selected
        }
    }
    #elseif os(macOS)
    func setSelectedImages(images: [URL]) {
        guard !images.isEmpty else { return }
        selectedImages = images.map { SavaImage(url: $0) }
        state = .selected
    }
    #endif
    
    func resizeImages(with outputSize: OutputSize) async throws {
        guard !selectedImages.isEmpty else { return }
        var resized: [ResizedImage] = []
        var errorOccured = false
        for image in selectedImages {
            do {
                #if os(iOS)
                let image = try SwiftImgResize.resize(
                    image: image.wrappedImage,
                    width: CGFloat(outputSize.width),
                    height: CGFloat(outputSize.height)
                )
                #elseif os(macOS)
                let image = try SwiftImgResize.resize(
                    imageURL: image.url,
                    width: CGFloat(
                        outputSize.width
                    ),
                    height: CGFloat(
                        outputSize.height
                    )
                )
                #endif
                resized.append(image)
            } catch {
                errorOccured = true
            }
        }
        guard !resized.isEmpty, !errorOccured else {
            throw Error.failedResizing
        }
        resizedImages = resized
        state = .resized
    }
    
    #if os(iOS)
    func saveToCameraRoll() {
        guard resizedImages.count > 0 else { return }
        for image in resizedImages {
            UIImageWriteToSavedPhotosAlbum(image.wrappedImage, #selector(didSaveImageToCameraRoll), nil, nil)
        }
    }
    #endif
    
    @objc private func didSaveImageToCameraRoll() {
        
    }
    
    func deselect(image: SavaImage) {
        selectedImages.removeAll { $0 == image }
        if selectedImages.isEmpty {
            self.state = .idle
        }
    }
    
    func clear() {
        selectedImages = []
        self.state = .idle
    }
}
