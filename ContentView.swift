import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()

            Button(action: {
                print("OKボタンが押されました")
            }) {
                Text("OK")
                    .font(.title)
                    .padding()
                    .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}
