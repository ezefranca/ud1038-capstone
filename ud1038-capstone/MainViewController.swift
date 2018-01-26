//
//  ViewController.swift
//  ud1038-capstone
//
//  Created by Ezequiel on 11/11/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import UIKit
import datamuse_swift
import Vision

class MainViewController: UIViewController, SpeecherDelegate {
    
    @IBOutlet var speedRaterSlider: UISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var lyricsTextView: UITextView!
    @IBOutlet var predictionView: PredictionView!
    @IBOutlet var photoSourceView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var speecher:Speecher?
    var dataClient:DataMuseClient = DataMuseClient()
    let mobileNet = GoogLeNetPlaces()
    let imagePickerController = UIImagePickerController()
    var currentPrediction: String?
    var currentBeat : Beat = .one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.speecher?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func selectBeatTapped(_ sender: UISegmentedControl) {
        
        self.speecher?.pause()
        
        switch sender.selectedSegmentIndex {
        case 0:
            currentBeat = .one
            self.play()
        case 1:
            currentBeat = .two
            self.play()
        case 2:
            currentBeat = .three
            self.play()
        default:
            currentBeat = .one
            self.play()
        }
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            showCameraNotAvailableAlert()
        }
    }
    
    @IBAction func selectPhoto() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if let sp = self.speecher?.isPlaying {
            if sp {
                self.speecher?.pause()
            } else {
                self.play()
            }
        }
        else {
            self.play()
        }
    }
    
    func play() {
        self.lyricsTextView.text = ""
        self.dataClient.wordsThatRhyme(with: currentPrediction!, completion: { (words, error) in
            DispatchQueue.main.async {
                for word in words! {
                    if let w = word.word {
                        self.lyricsTextView.text.append("\("\n")\(RandomPhrase.randomWord())\(w)")
                    }
                }
                let config = ConfigurationBeat(beat: self.currentBeat, rate: self.speedRaterSlider.value)
                self.speecher = Speecher(text: self.lyricsTextView.text, config: config)
                self.speecher?.play()
            }
        })
    }
    
    func didFinish() {
        self.speecher?.stop()
    }
    
    // MARK: Private
    
    private func setupPrediction(prediction: String) {
        predictionView.predictionResultLabel.text = prediction
        predictionView.isHidden = false
        photoSourceView.isHidden = true
        currentPrediction = prediction
    }
    
    private func clearPrediction() {
        predictionView.isHidden = true
        photoSourceView.isHidden = false
        predictionView.predictionResultLabel.text = nil
        imageView.image = nil
        currentPrediction = nil
    }
    
    private func classifyPlace(image: UIImage) {
        // 1. Create the vision model, VNCoreMLModel
        guard let visionCoreMLModel = try? VNCoreMLModel(for: mobileNet.model) else {
            fatalError("Unable to convert to Vision Core ML Model")
        }
        
        // 2. Create the request, VNCoreMLRequest
        let placeClassificationRequest = VNCoreMLRequest(model: visionCoreMLModel,
                                                         completionHandler: self.handlePlaceClassificationResults)
        
        // 3. Create the request handler, VNImageRequestHandler
        guard let cgImage = image.cgImage else {
            fatalError("Unable to convert \(image) to CGImage.")
        }
        let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
        
        // 4. Call perform on the request handler with the request
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([placeClassificationRequest])
            } catch {
                print("Error performing place classification")
            }
        }
    }
    
    // 5. Handle the place classification results
    private func handlePlaceClassificationResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation],
                let topClassification = classifications.first else {
                    self.showRecognitionFailureAlert()
                    return
            }
            
            self.setupPrediction(prediction: topClassification.identifier)
        }
    }
    
    private func showRecognitionFailureAlert() {
        let alertController = UIAlertController.init(title: "Recognition Failure", message: "Please try another image.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showCameraNotAvailableAlert() {
        let alertController = UIAlertController.init(title: "Camera Not Available", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - RecognizerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = imageSelected
            classifyPlace(image: imageSelected)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

