//
//  ViewController.swift
//  Sentiment Studio Mobile
//
//  Created by Ethan Xu on 2024-04-13.
//

import Foundation
import AVFoundation
import UIKit

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var imageView: UIImageView!
    var button: UIButton!
    var cameraView: UIView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var stillImageOutput: AVCapturePhotoOutput!
    var captureDevice: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView = UIView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cameraView)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        button = UIButton(type: .system)
        button.setTitle("Capture Photo", for: .normal)
        button.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: cameraView.trailingAnchor, constant: 100),
            imageView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        
        setupCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func capturePhoto(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                let settings = AVCapturePhotoSettings()
                self.stillImageOutput.capturePhoto(with: settings, delegate: self)
            } else {
                debugPrint("Camera cannot accessed")
            }
        }
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if discoverySession.devices.count > 0 {
            captureDevice = discoverySession.devices.first
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(input)
            
            stillImageOutput = AVCapturePhotoOutput()
            captureSession.addOutput(stillImageOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.connection?.videoRotationAngle = 0
            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            cameraView.layer.addSublayer(videoPreviewLayer)
            
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                imageView.image = image
                sendImageData(imageData: imageData)
            }
        }
    }
    
    func sendImageData(imageData: Data) {
        let urlString = "https://sentiment-studio-api.loca.lt/video_feed"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Image = "data:image/png;base64," + imageData.base64EncodedString()
        let json: [String: Any] = ["image": base64Image]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                print("Server returned an error: \(httpResponse.statusCode)")
            } else if let data = data {
                print("Received data: \(data)")
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let json = jsonObject as? [String: Any] else {
                        print("Failed to cast JSON object to [String: Any]")
                        return
                    }
                    
                    guard let base64StringWithPrefix = json["image"] as? String else {
                        print("Failed to get 'image' from JSON")
                        return
                    }
                    
                    let base64Prefix = "data:image/jpeg;base64,"
                    guard base64StringWithPrefix.hasPrefix(base64Prefix) else {
                        print("Base64 string does not have expected prefix")
                        return
                    }
                    
                    let base64String = String(base64StringWithPrefix.dropFirst(base64Prefix.count))
                    guard let imageData = Data(base64Encoded: base64String) else {
                        print("Failed to decode base64 string into Data")
                        return
                    }
                    
                    guard let receivedImage = UIImage(data: imageData) else {
                        print("Failed to create UIImage from Data")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let targetSize = CGSize(width: 1000, height: 1000)
                        let sourceRect = CGRect(x: (receivedImage.size.width - targetSize.width) / 2, y: (receivedImage.size.height - targetSize.height) / 2, width: targetSize.width, height: targetSize.height)
                        
                        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
                        
                        let context = UIGraphicsGetCurrentContext()
                        
                        switch UIDevice.current.orientation {
                        case .portrait:
                            break
                        case .portraitUpsideDown:
                            context?.rotate(by: .pi)
                        case .landscapeLeft:
                            context?.rotate(by: .pi / 2)
                        case .landscapeRight:
                            context?.rotate(by: -.pi / 2)
                        default:
                            break
                        }
                        
                        if let croppedImage = receivedImage.cgImage?.cropping(to: sourceRect) {
                            let newImage = UIImage(cgImage: croppedImage)
                            newImage.draw(in: CGRect(origin: .zero, size: targetSize))
                            self.imageView.image = newImage
                        }
                        
                        UIGraphicsEndImageContext()
                    }
                } catch {
                    print("Failed to parse received data into JSON: \(error)")
                }
            }
        }
        task.resume()
    }
    
    @objc func handleDeviceOrientationChange() {
        guard let connection = videoPreviewLayer.connection else {
            return
        }
        
        let rotationAngle: CGFloat
        switch UIDevice.current.orientation {
        case .portrait:
            rotationAngle = 90
        case .portraitUpsideDown:
            rotationAngle = -90
        case .landscapeLeft:
            rotationAngle = 180
        case .landscapeRight:
            rotationAngle = 0
        default:
            return
        }
        
        guard connection.isVideoRotationAngleSupported(rotationAngle) else {
            return
        }
        
        connection.videoRotationAngle = rotationAngle
    }
}
