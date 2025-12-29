import SwiftUI

enum CircleState {
    case following
    case flying
    case disappearing
}

struct ContentView: View {
    @State private var circlePosition: CGPoint = .zero
    @State private var circleColor: Color = Color.purple.opacity(0.3)
    @State private var circleSize: CGFloat = 50
    @State private var targetColor: Color = Color.purple.opacity(0.3)
    @State private var targetSize: CGFloat = 50
    @State private var isVisible: Bool = false
    @State private var circleState: CircleState = .following
    @State private var velocity: CGPoint = .zero
    @State private var lastPosition: CGPoint = .zero
    @State private var screenSize: CGSize = .zero

    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                if isVisible {
                    Circle()
                        .fill(circleColor)
                        .frame(width: circleSize, height: circleSize)
                        .position(circlePosition)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChanged(value: value, screenSize: geometry.size)
                    }
                    .onEnded { value in
                        handleDragEnded(value: value, screenSize: geometry.size)
                    }
            )
            .onAppear {
                screenSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                screenSize = newSize
            }
        }
        .onReceive(timer) { _ in
            updatePhysics()
            updateColorAndSize()
        }
    }

    func handleDragChanged(value: DragGesture.Value, screenSize: CGSize) {
        let touchPoint = value.location

        if !isVisible {
            // 新しい円を作成
            isVisible = true
            circleState = .following
            circlePosition = touchPoint
            lastPosition = touchPoint
            circleColor = Color.purple.opacity(0.3)
            targetColor = Color.purple.opacity(0.3)
            circleSize = 50
            targetSize = 50
            velocity = .zero
        } else if circleState == .flying {
            // 飛んでいる円をタッチで捕まえる
            let distance = sqrt(pow(touchPoint.x - circlePosition.x, 2) + pow(touchPoint.y - circlePosition.y, 2))
            if distance < circleSize / 2 + 30 {
                circleState = .following
                velocity = .zero
            }
        }

        if circleState == .following {
            // 指に追随
            circlePosition = touchPoint
            velocity = CGPoint(
                x: (touchPoint.x - lastPosition.x) * 0.8,
                y: (touchPoint.y - lastPosition.y) * 0.8
            )
            lastPosition = touchPoint

            // 色とサイズをゆったり変更
            if Int.random(in: 0...10) == 0 {
                targetColor = Color(
                    red: Double.random(in: 0...1),
                    green: Double.random(in: 0...1),
                    blue: Double.random(in: 0...1)
                ).opacity(Double.random(in: 0.3...0.8))
            }
            if Int.random(in: 0...10) == 0 {
                targetSize = CGFloat.random(in: 40...120)
            }
        }
    }

    func handleDragEnded(value: DragGesture.Value, screenSize: CGSize) {
        if circleState == .following {
            let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)

            if speed > 5 {
                // シュッと動かした場合：飛んでいく
                circleState = .flying
            } else {
                // ゆっくり離した場合：消える
                circleState = .disappearing
                withAnimation(.easeOut(duration: 1.0)) {
                    targetSize = 0
                }
            }
        }
    }

    func updatePhysics() {
        if circleState == .flying {
            // 位置を更新
            circlePosition.x += velocity.x
            circlePosition.y += velocity.y

            // 重力
            velocity.y += 0.3

            // 画面端で跳ね返る
            let radius = circleSize / 2
            if circlePosition.x - radius < 0 {
                circlePosition.x = radius
                velocity.x = -velocity.x * 0.8
            } else if circlePosition.x + radius > screenSize.width {
                circlePosition.x = screenSize.width - radius
                velocity.x = -velocity.x * 0.8
            }

            if circlePosition.y - radius < 0 {
                circlePosition.y = radius
                velocity.y = -velocity.y * 0.8
            } else if circlePosition.y + radius > screenSize.height {
                circlePosition.y = screenSize.height - radius
                velocity.y = -velocity.y * 0.8
            }

            // 速度の減衰
            velocity.x *= 0.98
            velocity.y *= 0.98

            // サイズを徐々に小さく
            targetSize = max(0, targetSize - 0.3)

            // 完全に小さくなったら消す
            if targetSize < 5 {
                isVisible = false
                circleState = .following
            }
        } else if circleState == .disappearing {
            if targetSize < 5 {
                isVisible = false
                circleState = .following
            }
        }
    }

    func updateColorAndSize() {
        // 色をスムーズに変化（ターゲット色に徐々に近づける）
        let progress: Double = 0.1
        if circleColor != targetColor {
            circleColor = targetColor
        }

        // サイズをスムーズに変化
        let sizeDiff = targetSize - circleSize
        circleSize += sizeDiff * 0.05
    }
}
