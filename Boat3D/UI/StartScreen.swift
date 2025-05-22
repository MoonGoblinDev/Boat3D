import SwiftUI

struct StartScreen: View {
    @State private var isAnimating: Bool = false
    @State private var textOffsetY: CGFloat = 0

    var body: some View {
        ZStack{
            SkyboxView(textureName: "Skybox", rotationDuration: 120) // Texture name from Assets
                            .edgesIgnoringSafeArea(.all)
                
            VStack{
                Image("Logo1")
                    .resizable()
                    .frame(width: 300, height: 300)
                Spacer()
                Text("Tap anywhere to start")
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .offset(y: textOffsetY)
                    .animation(
                        Animation.easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true),
                        value: textOffsetY
                    )
                Spacer().frame(height: 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
           
            textOffsetY = -5
        }
    }
}

#Preview {
    StartScreen()
}
