import SwiftUI

struct ContentView: View {
    @State private var totalSessions: Int = 0
    @State private var currentSession: Int = 0
    @State private var isWorking: Bool = true
    @State private var timeRemaining: Int = 0
    @State private var isTimerRunning: Bool = false
    @State private var showSessionPicker: Bool = false
    @State private var selectedSessions: Int = 1

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer()

            // セッション情報
            Text("セッション \(currentSession)/\(totalSessions)")
                .font(.title3)
                .padding(.bottom, 10)

            Text(isWorking ? "作業時間" : "休憩時間")
                .font(.headline)
                .foregroundColor(isWorking ? .blue : .green)
                .padding(.bottom, 20)

            // ドーナツ状の円グラフ
            ZStack {
                // 背景の円
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                    .frame(width: 250, height: 250)

                // 進捗を示す円
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isWorking ? Color.blue : Color.green,
                        style: StrokeStyle(lineWidth: 30, lineCap: .butt)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)

                // 残り時間表示
                VStack {
                    Text(timeString)
                        .font(.system(size: 48, weight: .bold))
                    Text("残り")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 30)

            Spacer()

            // 開始/停止ボタン
            Button(action: {
                if !isTimerRunning && totalSessions == 0 {
                    // セッション選択ダイアログを表示
                    showSessionPicker = true
                } else if isTimerRunning {
                    // タイマー停止
                    stopTimer()
                } else {
                    // タイマー再開
                    isTimerRunning = true
                }
            }) {
                Text(buttonTitle)
                    .font(.title2)
                    .padding()
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 50)
        }
        .alert("セッション数を選択", isPresented: $showSessionPicker) {
            ForEach(1...5, id: \.self) { number in
                Button("\(number)セッション") {
                    startPomodoro(sessions: number)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("1セッション = 25分作業 + 5分休憩")
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                tick()
            }
        }
    }

    var progress: Double {
        let totalTime = isWorking ? 25 * 60 : 5 * 60
        return Double(timeRemaining) / Double(totalTime)
    }

    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var buttonTitle: String {
        if totalSessions == 0 {
            return "開始"
        } else if isTimerRunning {
            return "停止"
        } else {
            return "再開"
        }
    }

    func startPomodoro(sessions: Int) {
        totalSessions = sessions
        currentSession = 1
        isWorking = true
        timeRemaining = 25 * 60 // 25分
        isTimerRunning = true
    }

    func stopTimer() {
        isTimerRunning = false
    }

    func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // 時間切れ - 次のフェーズへ
            if isWorking {
                // 作業時間終了 -> 休憩時間へ
                isWorking = false
                timeRemaining = 5 * 60 // 5分休憩
            } else {
                // 休憩時間終了
                if currentSession < totalSessions {
                    // 次のセッションへ
                    currentSession += 1
                    isWorking = true
                    timeRemaining = 25 * 60 // 25分
                } else {
                    // 全セッション完了
                    isTimerRunning = false
                    totalSessions = 0
                    currentSession = 0
                    timeRemaining = 0
                }
            }
        }
    }
}
