//
//  main.swift
//  分类图片
//
//  Created by yangkang on 2021/3/21.
//

import CoreML
import Foundation
import Vision

/// - Tag: MLModelSetup
var classificationRequest: VNCoreMLRequest = {
    do {
        /*
         Use the Swift class `MobileNet` Core ML generates from the model.
         To use a different Core ML classifier model, add it to the project
         and replace `MobileNet` with that model's generated Swift class.
         */
        let model = try VNCoreMLModel(for: mybeau_1().model)
//            print(model)
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let classifications = request.results as? [VNClassificationObservation] {
//                        let res:String = List(classifications)[0]
                print(classifications)
            }
        }
        request.imageCropAndScaleOption = .centerCrop
//            print(request)
        return request
    } catch {
        fatalError("Failed to load Vision ML model: \(error)")
    }
}()

/// - Tag: PerformRequests
func updateClassifications(image: URL) {
//        DispatchQueue.global(qos: .userInitiated).async {
    let handler = VNImageRequestHandler(url: image)
    do {
        try handler.perform([classificationRequest])
    } catch {
        /*
         This handler catches general image processing errors. The `classificationRequest`'s
         completion handler `processClassifications(_:error:)` catches errors specific
         to processing that request.
         */
        print("Failed to perform classification.\n\(error.localizedDescription)")
    }
//        }
}

/// Updates the UI with the results of the classification.
/// - Tag: ProcessClassifications

func processClassifications(for request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
    guard let results = request.results else {
        print("Unable to classify image.\n\(error!.localizedDescription)")
        return
    }
    // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
    let classifications = results as! [VNClassificationObservation]

    if classifications.isEmpty {
        print("Nothing recognized.")
    } else {
        // Display top classifications ranked by confidence in the UI.
        let topClassifications = classifications.prefix(2)
        let descriptions = topClassifications.map { classification in
            // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
            String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
        }
        print("Classification:\n" + descriptions.joined(separator: "\n"))
    }
//        }
}

let fileManager = FileManager.default
let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
do {
    let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
    // process files
    for eachfile in fileURLs {
        print(eachfile)
        updateClassifications(image: eachfile)
    }
} catch {
    print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
}
