import SwiftUI

struct RingTimerView: View {
    var progress: Double
    var isRunning: Bool
    var timeString: String
    var size: CGFloat = 260

    @State private var pulseScale1: CGFloat = 1.0
    @State private var pulseScale2: CGFloat = 1.0
    @State private var pulseOpacity1: Double = 0.4
    @State private var pulseOpacity2: Double = 0.25

    var body: some View {
        ZStack {
            // Pulse rings when running
            if isRunning {
                Circle()
                    .stroke(Color(hex: "#D4607E").opacity(pulseOpacity1), lineWidth: 2)
                    .frame(width: size + 30, height: size + 30)
                    .scaleEffect(pulseScale1)

                Circle()
                    .stroke(Color(hex: "#F07A5A").opacity(pulseOpacity2), lineWidth: 1.5)
                    .frame(width: size + 55, height: size + 55)
                    .scaleEffect(pulseScale2)
            }

            // Track ring
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 14)
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color(hex: "#F07A5A"), Color(hex: "#F5C26A"), Color(hex: "#D4607E")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Time text
            VStack(spacing: 4) {
                Text(timeString)
                    .font(.custom("DM Mono", size: 42).bold())
                    .foregroundColor(.white)
                    .monospacedDigit()
                Text(isRunning ? "focusing" : "ready")
                    .font(.custom("DM Sans", size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
        .onAppear {
            if isRunning { startPulse() }
        }
        .onChange(of: isRunning) { running in
            if running { startPulse() }
        }
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale1 = 1.06
            pulseOpacity1 = 0.1
        }
        withAnimation(.easeInOut(duration: 2.0).delay(0.3).repeatForever(autoreverses: true)) {
            pulseScale2 = 1.08
            pulseOpacity2 = 0.06
        }
    }
}
