//
//  SuccessAlertView.swift
//  sava
//
//  Created by Mirza Učanbarlić on 3. 2. 2024..
//

import SwiftUI

struct SuccessAlertView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let timeout: DispatchTimeInterval = .seconds(2)
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "photo.badge.checkmark")
                .resizable()
                .frame(width: 84, height: 74)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.all, 44)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                dismiss()
            }
        }
    }
}

#Preview {
    SuccessAlertView(title: "Success jedan dva tri!")
}
