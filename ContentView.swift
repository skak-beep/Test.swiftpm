import SwiftUI

struct DrawingCircle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
}

struct ContentView: View {
    @State private var circles: [DrawingCircle] = []
    @State private var isDragging: Bool = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ForEach(circles) { circle in
                Circle()
                    .fill(circle.color)
                    .frame(width: 50, height: 50)
                    .position(circle.position)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        // タップ時：薄紫色の円
                        isDragging = true
                        let newCircle = DrawingCircle(
                            position: value.location,
                            color: Color.purple.opacity(0.3)
                        )
                        circles.append(newCircle)
                    } else {
                        // ドラッグ中：ランダムな色の円
                        let randomColor = Color(
                            red: Double.random(in: 0...1),
                            green: Double.random(in: 0...1),
                            blue: Double.random(in: 0...1)
                        ).opacity(0.6)
                        let newCircle = DrawingCircle(
                            position: value.location,
                            color: randomColor
                        )
                        circles.append(newCircle)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }
}
