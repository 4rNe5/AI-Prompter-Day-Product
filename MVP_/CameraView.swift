//
//  CameraView.swift
//  MVP_
//
//  Created by 4rNe5 on 2023/09/03.
//

import SwiftUI
import AVFoundation

class CameraController: NSObject, AVCapturePhotoCaptureDelegate {
    var image: UIImage?
    let session = AVCaptureSession()
    let output = AVCapturePhotoOutput()

    override init() {
        super.init()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                session.addInput(input)
                session.addOutput(output)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
        }
    }
}

struct CameraView : UIViewRepresentable {

  @Binding var image : Image?
  @Binding var didTapCapture : Bool

  let cameraController = CameraController()

  func makeUIView(context : Context) -> UIView {

      // Configure the camera session
      cameraController.session.startRunning()

      // Create a preview layer
      let previewLayer = AVCaptureVideoPreviewLayer(session : cameraController.session)

      // Create a view to host the preview layer
      let cameraView = UIView(frame : UIScreen.main.bounds)

      // Ensure the preview layer fills the view and add it to the hierarchy
      previewLayer.frame.size.height += 1   // Fix for notch cutout
      cameraView.layer.addSublayer(previewLayer)

      return cameraView;
   }

   func updateUIView(_ uiView:UIView , context : Context){
       if self.didTapCapture{
           self.cameraController.takePhoto()
           DispatchQueue.main.asyncAfter(deadline:.now()+1){
               self.image=Image(uiImage:self.cameraController.image!)
               self.didTapCapture=false;
           }
       }
   }

}

#Preview {
    StartView()
}
