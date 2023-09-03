import SwiftUI
import VisionKit
import Vision

struct StartView: View {
    @State private var recognizedText = ""
    @State private var summaryText = ""
    @State private var isShowingScannerView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                GeometryReader { geometry in
                    TextArea(text: $recognizedText, placeholder:"스캔하여 인식된 택스트가 이곳에 표시됩니다.먼저 스캔 시작하기를 눌러 글자를 스캔하세요!!")
                        .frame(width: geometry.size.width, height: geometry.size.height/1.2)
                        .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 5)
                            )

                            .padding(.top, 20)
                    }
                GeometryReader { geometry in
                    TextArea(text: $recognizedText, placeholder:"GPT가 요약한 문서의 내용이 이곳에 표시됩니다! 요약 정리 시작하기를 눌러 내용을 정리해보세요!ㄱ")
                        .frame(width: geometry.size.width, height: geometry.size.height/1.5)
                        .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 5)
                            )

                            .padding(.top, 5)
                    }
                Button(action:{
                    self.isShowingScannerView = true
                }) {
                    Text("\(Image(systemName:"camera.circle.fill"))   스캔 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                NavigationLink(destination: AISummaryView(recognizedText: $recognizedText)) {
                    Text("\(Image(systemName:"square.and.pencil.circle.fill"))   요약정리 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)

            }.padding()
            // Display ScannerCoordinator as sheet when isShowingScannerView is true.
            // After scanning and recognizing text, navigate to ConfirmTextView with recognized text.
            // Dismiss the sheet after navigating to ConfirmTextView.
            .sheet(isPresented:$isShowingScannerView){
                NavigationView{
                    ScannerCoordinator(recognizedText:self.$recognizedText) { text in
                        self.recognizedText = text
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
}

struct ScannerCoordinator : UIViewControllerRepresentable {

   @Binding var recognizedText:String
    
   var completionHandler:(String)->Void

   func makeCoordinator() -> Coordinator {
       return Coordinator(recognizedText: $recognizedText, completionHandler: completionHandler)
   }

   func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
      let viewController = VNDocumentCameraViewController()
      viewController.delegate = context.coordinator
      return viewController
  }

  func updateUIViewController(_ uiViewController:
                                  VNDocumentCameraViewController, context:
                                  Context) {}

}

    class Coordinator:NSObject,VNDocumentCameraViewControllerDelegate{
        
        @Binding var recognizedText:String
        
        var completionHandler:(String)->Void
        
        init(recognizedText : Binding<String>,completionHandler:@escaping (String)->Void){
            _recognizedText=recognizedText
            self.completionHandler=completionHandler
            
        }
        
        func documentCameraViewController(_ controller :
                                          VNDocumentCameraViewController,didFinishWith scan :
                                          VNDocumentCameraScan){
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
            return images.map{CIImage(cgImage:$0).applyingFilter("CIPhotoEffectMono")}
            
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
                            self.completionHandler(self.recognizedText)
                            
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
        Group{

                StartView()

            }
    }
}
