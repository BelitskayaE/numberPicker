//
//  ViewController.swift
//  numberPicker
//
//  Created by Elisa on 18.09.2020.
//  Copyright © 2020 Elisa. All rights reserved.
//

import UIKit

struct ReadResult: Codable {
    var angle
    var height
    var lines
    var page
    var unit
    var width
    
}

struct AnalyzeResult: Codable {
    var readResult: ReadResult
    var version: String
}

struct Parsed: Codable {
    var analyzeResult: Dictionary<String,[Data]>
    var version: String
//    var readResults: String
//    var angle: String
//    var height: String
//    var lines: String
//    var text: String
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    var operationLocation: String = "" //var for get request
    
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
    
    private func createBody(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();

        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }

        let filename = "image.png"
        let mimetype = "image/png"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return body
    }
    
    
    var result: Dictionary<String, String> = [:]
    
    

    func getResults() {
        if(!operationLocation.isEmpty){
            let request = NSMutableURLRequest(url: NSURL(string: operationLocation)! as URL)
            request.httpMethod = "GET"
            request.addValue("", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    //Your HTTP request failed.
                    print(error?.localizedDescription as Any)
                } else {
                    //Your HTTP request succeeded
                  do {
                   
                    let parsedData = try JSONDecoder().decode(Parsed.self, from: data!)
                
                    if let httpResponse = response as? HTTPURLResponse {
                                   if(200 ... 299 ~= httpResponse.statusCode){
//                         self.result = parsedData
                         print("aaaaaaaaAAAA", parsedData)
                        
                        }
                        
                    }
                    
        

                    } catch let error as NSError {
                        print(error)
                    }
                    
//                    print("aaaaaaaA",String(data: data!, encoding: String.Encoding.utf8)!)
//
                }
            }.resume()
            
        }
    }
    
    
    
    func waitForGet(){
        repeat {
            sleep(20)
            self.getResults()
            
            break

        }
            while(true)
//        print("SelfResulttt",self.result)
    }

    func sendRequest(image:UIImage) {
        let resourceUrl = URL(string: "https://bnlwe-es01-d-901159-unilevercom-vision-api-01.cognitiveservices.azure.com/vision/v3.0/read/analyze")
        let compressedImage = image.pngData()
        let boundary = "--------69-69-69-69-69"
        var request = URLRequest(url: resourceUrl!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = createBody(parameters: nil, filePathKey: "file", imageDataKey: compressedImage!, boundary: boundary)
        
         _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(200 ... 299 ~= httpResponse.statusCode){
                    self.operationLocation = httpResponse.allHeaderFields["Operation-Location"] as! String
//                    print("Operation-Location",self.operationLocation)
                }
            }

//                 Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
            }
           
    }.resume()
       
    self.waitForGet()

     }
    
    
    
}
