import SwiftUI

struct ContentView: View {
    @State private var diceNumber: Int = 1
    @State private var history: [Int] = []

    var body: some View {
        VStack {
            Spacer()

            // 履歴表示（上から古い順、薄くなる）
            VStack(spacing: 5) {
                ForEach(Array(history.enumerated()), id: \.offset) { index, number in
                    Text("\(number)")
                        .font(.system(size: 40, weight: .medium))
                        .opacity(1.0 - Double(index) * 0.15)
                }
            }
            .padding(.bottom, 20)

            // 現在の数字
            Text("\(diceNumber)")
                .font(.system(size: 100, weight: .bold))
                .padding()

            Spacer()

            Button(action: {
                // 現在の数字を履歴の先頭に追加
                history.insert(diceNumber, at: 0)
                // 履歴が10個を超えたら古いものを削除
                if history.count > 10 {
                    history.removeLast()
                }
                // 新しい数字を生成
                diceNumber = Int.random(in: 1...6)
            }) {
                Text("ダイスを振る")
                    .font(.title2)
                    .padding()
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 50)
        }
    }
}
