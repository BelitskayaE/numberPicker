//
//  ViewController.swift
//  numberPicker
//
//  Created by Elisa on 18.09.2020.
//  Copyright © 2020 Elisa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

       
    
    //make a photo
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var ImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func ButtonClicked(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true,completion: nil)
        ImageView.image = info[.editedImage] as? UIImage
        sendRequest(image:ImageView.image!)
    }
    
    //send request to ocr
    let resourceString = "https://westus.api.cognitive.microsoft.com/vision/v2.0/ocr?"
    
    let parameters: [String : String] = [
               "language": "en",
               "detectOrientation": "true",
           ]

    
    func sendRequest(image:UIImage) {
        let resourceStringWithParams = resourceString + parameters["language"]! + parameters["detectOrientation"]!
        let resourceUrl = URL(string: resourceStringWithParams)
        var request = URLRequest(url: resourceUrl!)
        request.httpMethod = "POST"
        let requestBody = image.jpegData(compressionQuality: 100)
        request.httpBody = requestBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
        
    }
    

    
    


}

