//
//  Analyzer.swift
//  ud1038-capstone
//
//  Created by Ezequiel on 11/11/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import Foundation
import UIKit
import Vision

public protocol Analyzable : class {
    func modelAnalyzedDone(classification:VNClassificationObservation?, error: Error?)
}

public class Analyzer {
    
    private var delegate:Analyzable
    private let googleNet = GoogLeNetPlaces()
    
    init(_ delegate:Analyzable) {
        self.delegate = delegate
    }
    
    public func classifyPlace(image: UIImage) {
        
        guard let visionCoreMLModel = try? VNCoreMLModel(for: googleNet.model) else {
            fatalError("Unable to convert to Vision Core ML Model")
        }
        
        let placeClassificationRequest = VNCoreMLRequest(model: visionCoreMLModel,
                                                        completionHandler: self.handleplacesClassificationResults)
        
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([placeClassificationRequest])
            } catch {
                print("Error performing place classification")
            }
        }
    }

    private func handleplacesClassificationResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                let topClassification = classifications.first else {
                    self.delegate.modelAnalyzedDone(classification: nil, error: error)
                    return
            }
            self.delegate.modelAnalyzedDone(classification: topClassification, error: error)
        }
    }
    
}
