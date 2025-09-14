import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            // Background using green
            Color(red: 0.373, green: 0.424, blue: 0.216) // #5F6C37 Olive Green
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Clothespin Logo - using actual logo image
                VStack(spacing: 16) {
                    // Clothespin wordmark from Assets
                    Image("Logo")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            print("Logo image loaded: \(UIImage(named: "Logo") != nil)")
                        }
                }
                .zIndex(1) // Ensure logo is on top layer
                
                // Tagline - shorter version
                Text("get the most out of your closet")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.white) // Changed to white for better visibility
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 0.7 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .zIndex(1) // Ensure text is on top layer
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // White for better visibility
                        .scaleEffect(1.2) // Larger size
                    
                    Text("loading...")
                        .font(.custom("Poppins-Regular", size: 16)) // Larger text
                        .foregroundColor(.white) // White for better visibility
                }
                .padding(.bottom, 50)
                .zIndex(1) // Ensure loading indicator is on top layer
            }
        }
        .onAppear {
            isAnimating = true
            
            // Simulate loading time and then show main app
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMainApp = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
