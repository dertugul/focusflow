import SwiftUI

struct AvatarView: View {
    var user: User? = nil
    var name: String = ""
    var colorHex: String = "#F07A5A"
    var photoData: Data? = nil
    var size: CGFloat = 44
    var showRing: Bool = false

    var initials: String {
        let n = user?.name ?? name
        let parts = n.components(separatedBy: " ")
        if parts.count >= 2 {
            return String((parts[0].first ?? Character(" "))).uppercased() +
                   String((parts[1].first ?? Character(" "))).uppercased()
        }
        return String(n.prefix(2)).uppercased()
    }

    var avatarColor: Color {
        Color(hex: user?.avatarColor ?? colorHex)
    }

    var body: some View {
        ZStack {
            if let data = user?.photoData ?? photoData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(avatarColor.opacity(0.85))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(initials)
                            .font(.system(size: size * 0.35, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    )
            }
        }
        .overlay(
            showRing ? Circle().stroke(avatarColor, lineWidth: 2) : nil
        )
    }
}
