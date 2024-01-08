import AVFoundation
import UIKit
import SwiftUI

// UIViewControllerの定義
class CameraUIViewController: UIViewController, AVCapturePhotoCaptureDelegate, ObservableObject {
    public var captureSession: AVCaptureSession
    public var videoInput: AVCaptureDeviceInput!
    public var photoOutput: AVCapturePhotoOutput
    
    @Published var image: UIImage?
    @State private var recognizedStrings: [String] = []
    private let recognizedStringsQueue = DispatchQueue(label: "MF.recognizedStringsQueue")
//    @State private var isAnotherViewPresented = false
//    カメラセッションをclassプロパティとして定義
    public init() {
        self.captureSession = AVCaptureSession()
        self.photoOutput = AVCapturePhotoOutput()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
        
        let previewView = PreviewView()
        previewView.videoPreviewLayer.session = self.captureSession
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        let captureButton = UIButton(type: .system)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)

        // ボタンの外観を設定
        captureButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        captureButton.imageView?.contentMode = .scaleAspectFit
        captureButton.tintColor = .white
        // ボーダーを追加
        captureButton.layer.borderWidth = 1
        captureButton.layer.borderColor = UIColor.white.cgColor
        captureButton.layer.cornerRadius = 40 // ボタンが円形なので、幅/2に設定

        // Auto Layout 制約を追加
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    func setupSession() {
            
        captureSession.beginConfiguration()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)

        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        let photoSetting = AVCapturePhotoSettings()
        photoSetting.flashMode = .off
        photoOutput.capturePhoto(with: photoSetting, delegate: self)
        
        captureSession.commitConfiguration()
    }
    @objc private func captureButtonTapped() {
         // キャプチャーロジックをここに追加
        print("Capture button tapped")
        let photoSetting = AVCapturePhotoSettings()
        photoSetting.flashMode = .off
        photoSetting.isHighResolutionPhotoEnabled = false
        
        photoOutput.capturePhoto(with: photoSetting, delegate: self)
        
        return
         
     }
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        if imageData != nil {
            self.image = UIImage(data: imageData!)
            textRecognition(uiimage: self.image!) { result in
                DispatchQueue.main.async {
                    print("\(result)")
                    
                    // Check if recognizedStrings has data
                    if !result.isEmpty {
                        // Present AnotherUIView with recognizedStrings data
                        let anotherView = AnotherUIView()
                        
                        anotherView.configure(recognizedStrings: result)
                        
                        self.view.addSubview(anotherView)
                        
                        // Add Auto Layout constraints for AnotherUIView
                        anotherView.translatesAutoresizingMaskIntoConstraints = false
                        
                        NSLayoutConstraint.activate([
                            anotherView.topAnchor.constraint(equalTo: self.view.topAnchor),
                            anotherView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                            anotherView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                            anotherView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                        ])
                        
                    }
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
         guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
             return nil
         }
         CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
         let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
         let width = CVPixelBufferGetWidth(pixelBuffer)
         let height = CVPixelBufferGetHeight(pixelBuffer)
         let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
         let colorSpace = CGColorSpaceCreateDeviceRGB()
         let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
         guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
             return nil
         }
         guard let cgImage = context.makeImage() else {
             return nil
         }
         let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
         CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
         return image
     }

//    Input設定
    private func connectInputsToSession() {
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
    }
//    Output設定
    private func connectOutputToSession() {
        let photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
    }
//    preview用画面UIView
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    class AnotherUIView: UIView {
        private var recognizedStrings: [String] = []
        private let label = UILabel()
        private let backButton = UIButton()

        init() {
            super.init(frame: .zero)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(recognizedStrings: [String]) {
            self.recognizedStrings = recognizedStrings
            updateUI()
        }

        @objc func backButtonTapped() {
            recognizedStrings = [] // Set empty list to recognizedStrings
            removeFromSuperview()
        }

        private func setupUI() {
            backgroundColor = .darkGray
            layer.cornerRadius = 10
            layer.masksToBounds = true

            label.textAlignment = .center
            addSubview(label)

            backButton.setTitle("Back", for: .normal)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            addSubview(backButton)

            setupConstraints()
        }

        func setupConstraints() {
            // Add Auto Layout constraints here
            label.translatesAutoresizingMaskIntoConstraints = false
            backButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

                backButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
                backButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                backButton.widthAnchor.constraint(equalToConstant: 80),
                backButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        private func updateUI() {
            label.text = "Data: \(recognizedStrings.joined(separator: ", "))"
            label.numberOfLines = 0 // Allow multiple lines
                label.lineBreakMode = .byWordWrapping
        }
    }
}
// CameraUIViewControllerをSwiftUIのViewに変換
struct AddTransactionByCameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraUIViewController
    func makeUIViewController(context: Context) ->  UIViewControllerType {
        return CameraUIViewController()
    }
    func updateUIViewController(_ uiViewController:  UIViewControllerType, context: Context) {
        
    }
}
