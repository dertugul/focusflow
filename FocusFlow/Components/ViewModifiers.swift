import SwiftUI

// MARK: - Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.035))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: 1, green: 220/255, blue: 180/255).opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Pill Style
struct PillStyle: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(color.opacity(0.18))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 0.8))
    }
}

extension View {
    func pillStyle(color: Color) -> some View {
        modifier(PillStyle(color: color))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    var hexString: String {
        let components = UIColor(self).cgColor.components ?? [0,0,0,1]
        let r = Int((components[0]) * 255)
        let g = Int((components[1]) * 255)
        let b = Int((components[2]) * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Breathe Modifier
struct BreatheModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    var isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear { if isActive { startBreathing() } }
            .onChange(of: isActive) { active in
                if active { startBreathing() } else { scale = 1.0 }
            }
    }

    private func startBreathing() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            scale = 1.05
        }
    }
}

extension View {
    func breatheEffect(isActive: Bool) -> some View {
        modifier(BreatheModifier(isActive: isActive))
    }
}

// MARK: - Play/Pause SVG Shapes
struct PlayShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PauseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let barW: CGFloat = rect.width * 0.28
        let gap: CGFloat = rect.width * 0.18
        let left = CGRect(x: rect.minX, y: rect.minY, width: barW, height: rect.height)
        let right = CGRect(x: rect.minX + barW + gap, y: rect.minY, width: barW, height: rect.height)
        path.addRoundedRect(in: left, cornerSize: CGSize(width: barW * 0.35, height: barW * 0.35))
        path.addRoundedRect(in: right, cornerSize: CGSize(width: barW * 0.35, height: barW * 0.35))
        return path
    }
}
