//
//  ContentView.swift
//  sava
//
//  Created by Mirza Učanbarlić on 23. 1. 2024..
//

import SwiftUI
import PhotosUI
import os

struct ContentView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var selectedOutputSize: OutputSize = .iPhone4
    @State private var error: AppError?
    @State private var isPresentingError = false
    @State private var isTargeted = false
    @State private var isSuccessAlertPresented = false
#if os(iOS)
    @State private var pickerItems: [PhotosPickerItem] = []
    private let columns = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
#elseif os(macOS)
    private let columns = [
        GridItem(.fixed(180), spacing: 12),
        GridItem(.fixed(180), spacing: 12),
        GridItem(.fixed(180), spacing: 12),
        GridItem(.fixed(180), spacing: 12)
    ]
#endif
    private let allowedContentTypes: [UTType] = [.image, .png, .jpeg]
    
    var body: some View {
        NavigationStack {
            VStack {
                switch appViewModel.state {
                case .idle:
                    idleView
                case .selected, .resized:
                    selectedView
                }
            }
        }
#if os(iOS)
        .fullScreenCover(isPresented: $isSuccessAlertPresented, onDismiss: {
            appViewModel.saveToCameraRoll()
        }, content: {
            SuccessAlertView(title: "Resizing Succeeded")
                .presentationBackground(.clear)
        })
#elseif os(macOS)
        .sheet(isPresented: $isSuccessAlertPresented, onDismiss: {
            isExporting = true
        }, content: {
            SuccessAlertView(title: "Resizing Succeeded")
                .presentationBackground(.clear)
        })
#endif
        .fileExporter(isPresented: $isExporting, documents: appViewModel.resizedImages, contentType: .png) { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                error = .exporting
            }
        }
#if os(iOS)
        .onChange(of: pickerItems) { _, newValue in
            appViewModel.setSelectedImages(images: newValue)
        }
#elseif os(macOS)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: allowedContentTypes, allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                urls.forEach { url in
                    let gotAccess = url.startAccessingSecurityScopedResource()
                    guard gotAccess else {
                        return
                    }
                }
                appViewModel.setSelectedImages(images: urls)
            case .failure(_):
                error = .importing
            }
        }
        .onDrop(of: [.url], isTargeted: $isTargeted, perform: { providers in
            var urls: [URL] = []
            let queue = DispatchQueue(label: "com.sava")
            let group = DispatchGroup()
            
            for provider in providers {
                if provider.canLoadObject(ofClass: URL.self) {
                    group.enter()
                    _ = provider.loadTransferable(type: URL.self) { result in
                        defer { group.leave() }
                        switch result {
                        case .success(let url):
                            guard url.isImageFile else { return }
                            queue.sync {
                                urls.append(url)
                            }
                            print(url)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                }
            }
            group.wait()
            appViewModel.setSelectedImages(images: urls)
            return true
        })
#endif
        .onChange(of: error, { _, newValue in
            isPresentingError = newValue != nil
        })
        .alert(isPresented: $isPresentingError, error: error) {
            Button("Ok", role: .none) {}
        }
    }
    
    private var idleView: some View{
        VStack {
            ContentUnavailableView("Drop images to resize.", systemImage: "photo.badge.plus")
#if os(iOS)
            PhotosPicker("Add", selection: $pickerItems, photoLibrary: .shared())
                .buttonStyle(.borderedProminent)
#elseif os(macOS)
            Button("Add") {
                isImporting = true
            }
            .buttonStyle(.borderedProminent)
#endif
        }
    }
    
    private var selectedView: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(appViewModel.selectedImages) { image in
                        SaveGridItemImageView(image: image)
                    }
                }
                .padding(.all, 12)
            }
            VStack {
                Text("\(appViewModel.selectedImages.count) items selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker(selection: $selectedOutputSize) {
                    ForEach(OutputSize.allCases) { outputSize in
                        HStack {
                            Image(systemName: outputSize.systemIconName)
                            Text("\(outputSize.name)  (\(outputSize.width) x \(outputSize.height)px) \(outputSize.isImportant ? "(Required)" : "")")
                            Spacer()
                            if outputSize.isImportant {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.yellow)
                            }
                        }
                        .tag(outputSize)
                    }
                } label: {
                    Text("Output Size")
                }
                Button {
                    Task {
                        do {
                            try await appViewModel.resizeImages(with: selectedOutputSize)
                            await MainActor.run {
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    isSuccessAlertPresented = true
                                }
                            }
                        } catch {
                            self.error = .resizing
                        }
                    }
                } label: {
                    Text("Resize")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(12)
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    withAnimation {
                        appViewModel.clear()
                    }
                }, label: {
                    HStack {
                        Text("Clear all")
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .fontWeight(.bold)
                    }
                })
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ContentView()
}
