//
//  SaveGridItemImageView.swift
//  sava
//
//  Created by Mirza Učanbarlić on 27. 1. 2024..
//

import SwiftUI
import Kingfisher

struct SaveGridItemImageView: View {
    @Environment(AppViewModel.self) private var appViewModel
    let image: SavaImage
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        appViewModel.deselect(image: image)
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .frame(width: 24, height: 24)
                        .bold()
                        .foregroundStyle(.secondary)
                })
                .buttonStyle(.plain)
            }
            #if os(iOS)
            Image(uiImage: image.wrappedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
            #elseif os(macOS)
            KFImage(image.url)
                .placeholder({
                    ProgressView()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 130)
                .clipped()
            #endif
            VStack {
                Text(image.name)
                Text("\(image.width)x\(image.height)px")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.all, 12)
        .savaItemBackground()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}

struct SavaGridItemImageViewBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
                .background(.ultraThinMaterial)
        } else {
            content
                .background(.ultraThickMaterial)
        }
    }
}

extension View {
    func savaItemBackground() -> some View {
        self.modifier(SavaGridItemImageViewBackground())
    }
}

#Preview {
    #if os(iOS)
    SaveGridItemImageView(image: .init(wrappedImage: UIImage(systemName: "macbook")!))
    #elseif os(macOS)
    SaveGridItemImageView(image: .init(url: URL(string: "https://supersonicbyte.com/supersonicbyte-profile.png")!))
    #endif
}
