import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var recognizedObject: String = ""
    @State private var showRecognition: Bool = false

    var body: some View {
        ZStack {
            // カメラプレビュー
            CameraPreview(cameraManager: cameraManager)
                .ignoresSafeArea()

            // 認識枠（画面中央）
            VStack {
                Spacer()

                ZStack {
                    // 認識枠
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow, lineWidth: 4)
                        .frame(width: 300, height: 300)

                    // ヘルプテキスト
                    if !showRecognition {
                        Text("ここに絵を写してください")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                    }
                }

                Spacer()

                // 認識結果表示
                if showRecognition {
                    VStack(spacing: 10) {
                        Text("認識しました！")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(recognizedObject)
                            .font(.title)
                            .fontWeight(.heavy)
                        Text("タップして動かそう")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(15)
                    .padding(.bottom, 50)
                } else {
                    // 認識ボタン
                    Button(action: {
                        simulateRecognition()
                    }) {
                        Text("認識する")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            cameraManager.checkPermission()
        }
    }

    func simulateRecognition() {
        // ランダムに認識結果をシミュレート
        let objects = [
            "🐕 犬が走り出しました！",
            "🚗 車が走り出しました！",
            "🐱 猫が踊っています！",
            "🦁 ライオンが吠えています！",
            "🚀 ロケットが飛んでいきました！",
            "🐘 ゾウが歩いています！",
            "🦋 蝶々が舞っています！"
        ]
        recognizedObject = objects.randomElement() ?? "何かを認識しました！"
        withAnimation {
            showRecognition = true
        }

        // 3秒後に認識結果をリセット
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showRecognition = false
                recognizedObject = ""
            }
        }
    }
}

// カメラマネージャー
class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var permissionGranted = false

    override init() {
        super.init()
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }

    func setupCamera() {
        session.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        session.commitConfiguration()
        session.startRunning()
    }
}

// カメラプレビュー
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
