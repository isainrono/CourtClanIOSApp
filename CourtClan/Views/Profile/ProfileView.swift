//
//  ProfileView.swift
//  RodMon
//
//  Created by Isain Rodriguez Noreña on 23/4/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var borderColor: Color = .green
    @State private var borderWidth: CGFloat = 2
    @State private var isAnimating: Bool = false
    @State private var hasNewActivity: Bool = true

    // MARK: - Customizable Properties
    let imageName: String // Name of the local image asset
    let circleSize: CGFloat
    let imageSize: CGFloat
    let shouldAnimateBorder: Bool // New property

    // MARK: - Initialization
    init(imageName: String, circleSize: CGFloat = 150, imageSize: CGFloat = 140, shouldAnimateBorder: Bool = false) {
        self.imageName = imageName
        self.circleSize = circleSize
        self.imageSize = imageSize
        self.shouldAnimateBorder = shouldAnimateBorder
    }

    var body: some View {
        VStack {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(borderColor, lineWidth: borderWidth)
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(isAnimating ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default, value: isAnimating)

                // Profile Image from local asset
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
            }
            .onAppear {
                if hasNewActivity && shouldAnimateBorder {
                    startBorderAnimation()
                } else if !shouldAnimateBorder {
                    stopBorderAnimation()
                }
            }
            .onChange(of: hasNewActivity) { newValue in
                if newValue && shouldAnimateBorder {
                    startBorderAnimation()
                } else {
                    stopBorderAnimation()
                    borderColor = .green
                }
            }

            .padding()
        }
    }

    func startBorderAnimation() {
        isAnimating = true
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation {
                let colors: [Color] = [.red, .green, .blue, .yellow, .purple]
                borderColor = colors.randomElement() ?? .green
            }
        }
    }

    func stopBorderAnimation() {
        isAnimating = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView(imageName: "user_placeholder")
                .previewDisplayName("Animated")

            ProfileView(imageName: "user_placeholder", shouldAnimateBorder: false)
                .previewDisplayName("No Animation")

            ProfileView(imageName: "user_placeholder", circleSize: 100, imageSize: 90, shouldAnimateBorder: false)
                .previewDisplayName("Smaller No Animation")
        }
    }
}

#Preview {
    ProfileView(imageName: "user_placeholder", circleSize: 80, imageSize: 70, shouldAnimateBorder: false)
}
