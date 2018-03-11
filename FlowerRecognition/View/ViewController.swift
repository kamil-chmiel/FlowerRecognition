//
//  ViewController.swift
//  FlowerRecognition
//
//  Created by Kamil Chmiel on 07.03.2018.
//  Copyright © 2018 Kamil Chmiel. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    let imagePicker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    var flowerName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.sizeToFit()
        imagePicker.delegate = self
    }

    // MARK: - UI Setting Part
    /**************************************/
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: image) else { fatalError("Error creating ciImage") }
            detection(flowerImage: ciImage)
        }
        else {
            print("There was an error picking the image")
        }
    }
    
    // MARK: - ML Classification Part
    /**************************************/
    func detection(flowerImage : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Loading CoreML Model failed") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image.") }
            
            if let firstResult = results.first {
                self.titleLabel.text = firstResult.identifier.capitalized
                self.flowerName = firstResult.identifier
                
                let parameters : [String:String] = [
                    "format" : "json",
                    "action" : "query",
                    "prop" : "extracts|pageimages",
                    "exintro" : "",
                    "explaintext" : "",
                    "titles" : self.flowerName,
                    "indexpageids" : "",
                    "redirects" : "1",
                    "pithumbsize" : "500"
                    ]
                
                self.getFlowerInfo(parameters: parameters)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print("Error performing classification request")
        }
    }
    
    // MARK: - Networking Part
    /**************************************/
    func getFlowerInfo(parameters : [String : String]) {
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                let wikipediaJSON : JSON = JSON(response.result.value!)
                
                print(wikipediaJSON)
                
                self.showFlowerInfo(json: wikipediaJSON)
            }
        }
        
    }
    
    // MARK: - JSON Parsing
    /**************************************/
    func showFlowerInfo(json: JSON) {
        
        if let pageid = json["query"]["pageids"][0].string {

            descriptionLabel.text = json["query"]["pages"][pageid]["extract"].stringValue
            let imageURL = json["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
            
            self.flowerImageView.sd_setImage(with: URL(string: imageURL))
        }
    }
}

