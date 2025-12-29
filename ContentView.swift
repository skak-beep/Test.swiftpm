import SwiftUI

struct ContentView: View {
    @State private var diceNumber: Int = 1

    var body: some View {
        VStack {
            Spacer()

            Text("\(diceNumber)")
                .font(.system(size: 100, weight: .bold))
                .padding()

            Spacer()

            Button(action: {
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
