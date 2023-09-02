import SwiftUI
import VisionKit
import Vision

struct StartView: View {
    @State private var recognizedText = ""
    @State private var isShowingScannerView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(recognizedText)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Button(action: {
                self.isShowingScannerView = true
            }) {
                Text("스캔 시작하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingScannerView) {
            ScannerView(recognizedText: self.$recognizedText)
        }
    }
}

struct ScannerView : UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(recognizedText: $recognizedText)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context:
                                    Context) {}
    
    class Coordinator:NSObject,VNDocumentCameraViewControllerDelegate{
        
        @Binding var recognizedText:String
        
         init(recognizedText : Binding<String>){
             _recognizedText=recognizedText
            
         }

         func documentCameraViewController(_ controller : VNDocumentCameraViewController,didFinishWith scan : VNDocumentCameraScan){
             let extractedImages=extractImages(from : scan);
             let processedImages=preprocess(extractedImages);
             recognize(processedImages);
             controller.dismiss(animated:true);
             
         }

         func extractImages(from scan : VNDocumentCameraScan)->[CGImage]{
              var images=[CGImage]()
              for pageNumber in 0..<scan.pageCount{
                  images.append(scan.imageOfPage(at : pageNumber).cgImage!)
              }
              return images;
             
          }


          func preprocess(_ images:[CGImage])->[CIImage]{
               return images.map{CIImage(cgImage:$0)}
              
          }


          func recognize(_ images:[CIImage]){
              let textRecognitionWorkQueue=DispatchQueue(label:"com.example.textRecognitionQueue",qos:.userInitiated,attributes:[],autoreleaseFrequency:.workItem)

               textRecognitionWorkQueue.async{

                   let recognizeInBlock={
                       (images:[CIImage]) in

                       //Prepare the requests and handlers

                       let textRecognitionRequest=VNRecognizeTextRequest{ (request,error) in
                           if let error=error{
                               print("Error:\(error)")
                           }else{
                               self.recognizedText=self.processResults(from:request)

                           }

                        }

                        textRecognitionRequest.recognitionLevel = .accurate
                        textRecognitionRequest.recognitionLanguages = ["ko-KR", "en-US"]
                        let requests=[textRecognitionRequest]

                        for image in images{

                            //Perform the request on each image

                            do{
                                try VNImageRequestHandler(ciImage:image,options:[:]).perform(requests)
                            }catch let error as NSError{
                                print("Failed to perform image request:\(error)")
                                return;
                            }

                         }

                   }
                   
                   recognizeInBlock(images)

               }

          }


          func processResults(from request : VNRequest)->String{

              guard let observations=request.results as? [VNRecognizedTextObservation] else {return "" }
              let recognizedStrings=observations.compactMap{observation in
                  return observation.topCandidates(1).first?.string
              }
              return recognizedStrings.joined(separator:"")

          }


    }

}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
