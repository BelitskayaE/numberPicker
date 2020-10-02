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

    func sendRequest(image:UIImage) {
        let resourceUrl = URL(string: "https://api.ocr.space/parse/image")
        let compressedImage = image.jpegData(compressionQuality: 400)
        let boundary = "--------69-69-69-69-69"
        var request = URLRequest(url: resourceUrl!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("fc26587bda88957", forHTTPHeaderField: "apikey" )
        request.httpBody = createBody(parameters: nil, filePathKey: "file", imageDataKey: compressedImage!, boundary: boundary)
       
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("ааааааааааааааа \(dataString)")
                    
                }
        }
        task.resume()
    
    }
    
    
    
    private func createBody(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();

        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }

        let filename = "image.jpeg"
        let mimetype = "image/jpeg"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey)
        body.append("\r\n".data(using: String.Encoding.utf8)!)

        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

        return body
    }
    
    

    

}

