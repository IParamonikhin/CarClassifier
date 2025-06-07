//
//  ContentView.swift
//  CarClassifier
//
//  Created by Иван on 04.05.2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = CarClassifierViewModel()
    @State private var showResultView = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Group {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 320)
                        .cornerRadius(18)
                        .shadow(radius: 10)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Загрузите фотографию автомобиля")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if viewModel.selectedImage != nil {
                Button(action: {
                    Task { await viewModel.classifyImage(viewModel.selectedImage!) }
                    showResultView = true
                }) {
                    Text("Определить")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(radius: 3)
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.pickImage(type: .photoLibrary)
                }) {
                    Label("Галерея", systemImage: "photo.on.rectangle")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
                Button(action: {
                    viewModel.pickImage(type: .camera)
                }) {
                    Label("Камера", systemImage: "camera")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: Binding(get: { viewModel.sourceType != nil }, set: { if !$0 { viewModel.sourceType = nil } })) {
            if let type = viewModel.sourceType {
                ImagePicker(sourceType: type) { image in
                    viewModel.selectedImage = image
                    viewModel.predictions = []
                }
            }
        }
        .fullScreenCover(isPresented: $showResultView) {
            ResultView(
                image: viewModel.selectedImage,
                predictions: viewModel.predictions,
                onClose: { showResultView = false }
            )
        }
    }
}
