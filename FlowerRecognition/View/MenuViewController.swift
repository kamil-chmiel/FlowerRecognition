//
//  ViewController.swift
//  FlowerRecognition
//
//  Created by Kamil Chmiel on 07.03.2018.
//  Copyright © 2018 Kamil Chmiel. All rights reserved.
//

import UIKit
import Alamofire
import Vision
import CoreML
import SwiftyJSON
import SVProgressHUD

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    var flowerName : String = ""
    var flowerDesc : String = ""
    var flowerImageURL: String = ""
    
    // MARK: - UI Setting Part
    /**************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationView = segue.destination as! DescriptionViewController
        destinationView.imageURL = flowerImageURL
        destinationView.name = flowerName.uppercased()
        destinationView.desc = flowerDesc
    }
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func libraryPressed(_ sender: UIButton) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        SVProgressHUD.show()
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
                self.showFlowerInfo(json: wikipediaJSON)
            }
        }
        
    }
    
    // MARK: - JSON Parsing
    /**************************************/
    
    func showFlowerInfo(json: JSON) {
        if let pageid = json["query"]["pageids"][0].string {
            flowerDesc = json["query"]["pages"][pageid]["extract"].stringValue
            flowerImageURL = json["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
        }
        SVProgressHUD.dismiss()
        performSegue(withIdentifier: "goToDescription", sender: nil)
    }
    
}

