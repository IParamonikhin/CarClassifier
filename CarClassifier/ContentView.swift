//
//  ContentView.swift
//  CarClassifier
//
//  Created by Иван on 04.05.2025.
//

import SwiftUI
import CoreML
import Vision
import PhotosUI
import UIKit

@MainActor
struct ContentView: View {
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @State private var predictions: [VNClassificationObservation] = []
    @State private var isShowResult = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }

                HStack(spacing: 16) {
                    Button("Выбрать из галереи") {
                        openPicker(for: .photoLibrary)
                    }
                    .padding()

                    Button("Сделать снимок") {
                        openPicker(for: .camera)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: Binding(get: { sourceType != nil }, set: { if !$0 { sourceType = nil } })) {
                if let type = sourceType {
                    ImagePicker(sourceType: type) { image in
                        selectedImage = image
                        Task { await classifyImage(image) }
                    }
                }
            }

            if isShowResult {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 12) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                    }
                    VStack(spacing: 4) {
                        ForEach(predictions.prefix(3), id: \.identifier) { p in
                            Text("\(p.identifier) — \(Int(p.confidence * 100))%")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    Button("Закрыть") { isShowResult = false }
                        .padding(6)
                        .background(.white.opacity(0.9))
                        .cornerRadius(10)
                }
                .padding()
                .background(.black.opacity(0.85))
                .cornerRadius(20)
                .padding()
            }
        }
    }

    private func openPicker(for type: UIImagePickerController.SourceType) {
        Task {
//            sourceType = nil
            sourceType = type
        }
    }

    private func classifyImage(_ image: UIImage) async {
        guard let model = try? VNCoreMLModel(for: MyCarClassifier().model) else { return }
        guard let ciImage = CIImage(image: image) else { return }
        let request = VNCoreMLRequest(model: model)
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
            if let results = request.results as? [VNClassificationObservation] {
                predictions = results
                isShowResult = true
            }
        } catch {
            print("Ошибка классификации: \(error.localizedDescription)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ContentView()
}
