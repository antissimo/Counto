import SwiftUI

enum BigActionButtonStyle {
    case primary
    case secondary
}

struct BigActionButtonLabel: View {
    let title: String
    let systemImage: String
    let style: BigActionButtonStyle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.title3.bold())
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(background)
        .foregroundStyle(foreground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var background: Color {
        style == .primary ? Color.accentColor : Color(.secondarySystemBackground)
    }

    private var foreground: Color {
        style == .primary ? .white : .primary
    }
}

struct BigActionButton: View {
    let title: String
    let systemImage: String
    let style: BigActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BigActionButtonLabel(title: title, systemImage: systemImage, style: style)
        }
        .buttonStyle(.plain)
    }
}
