import SwiftUI

struct ContentView: View {
    @State private var circlePosition: CGPoint = .zero
    @State private var circleColor: Color = Color.purple.opacity(0.3)
    @State private var circleSize: CGFloat = 50
    @State private var isVisible: Bool = false
    @State private var isDisappearing: Bool = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            if isVisible {
                Circle()
                    .fill(circleColor)
                    .frame(width: circleSize, height: circleSize)
                    .position(circlePosition)
                    .animation(.easeOut(duration: 0.3), value: circleSize)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isVisible {
                        // タップ時：薄紫色の円を表示
                        isVisible = true
                        isDisappearing = false
                        circlePosition = value.location
                        circleColor = Color.purple.opacity(0.3)
                        circleSize = 50
                    } else {
                        // ドラッグ中：位置を更新し、色とサイズをランダムに変更
                        circlePosition = value.location
                        circleColor = Color(
                            red: Double.random(in: 0...1),
                            green: Double.random(in: 0...1),
                            blue: Double.random(in: 0...1)
                        ).opacity(Double.random(in: 0.3...0.8))
                        circleSize = CGFloat.random(in: 30...100)
                    }
                }
                .onEnded { _ in
                    // 指を離したら円を小さくして消す
                    isDisappearing = true
                    withAnimation(.easeOut(duration: 0.5)) {
                        circleSize = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isVisible = false
                    }
                }
        )
    }
}
