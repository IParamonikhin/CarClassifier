//
//  ResultView.swift
//  CarClassifier
//
//  Created by Иван on 07.06.2025.
//

import SwiftUI
import Vision

struct ResultView: View {
    let image: UIImage?
    let predictions: [VNClassificationObservation]
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 320)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                }
                ForEach(predictions.prefix(3), id: \.identifier) { p in
                    Text("\(p.identifier) — \(Int(p.confidence * 100))%")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                Button("Закрыть", action: onClose)
                    .font(.headline)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.95))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding()
            .background(Color.black.opacity(0.92))
            .cornerRadius(24)
            .shadow(radius: 12)
        }
    }
}
