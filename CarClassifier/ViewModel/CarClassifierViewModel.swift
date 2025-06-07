//
//  CarClassifierViewModel.swift
//  CarClassifier
//
//  Created by Иван on 07.06.2025.
//

import SwiftUI
import CoreML
import Vision
import UIKit

@MainActor
class CarClassifierViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var predictions: [VNClassificationObservation] = []
    @Published var isShowResult = false
    @Published var sourceType: UIImagePickerController.SourceType?

    func pickImage(type: UIImagePickerController.SourceType) {
        sourceType = type
    }

    func classifyImage(_ image: UIImage) async {
        guard let model = try? VNCoreMLModel(for: MyCarClassifier().model) else { return }
        guard let ciImage = CIImage(image: image) else { return }
        let request = VNCoreMLRequest(model: model)
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
            if let results = request.results as? [VNClassificationObservation] {
                await MainActor.run {
                    self.predictions = results
                    self.isShowResult = true
                }
            }
        } catch {
            print("Ошибка классификации: \(error.localizedDescription)")
        }
    }

    func closeResult() {
        isShowResult = false
    }
}
