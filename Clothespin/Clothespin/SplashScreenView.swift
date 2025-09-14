import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            // Background using white
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Clothespin Logo - using actual logo image
                VStack(spacing: 16) {
                    // Clothespin wordmark from Assets
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                // Tagline - shorter version
                Text("get the most out of your closet")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color(red: 0.373, green: 0.424, blue: 0.216)) // #5F6C37 Olive Green
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 0.7 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.863, green: 0.631, blue: 0.365))) // #DCA15D Brown
                        .scaleEffect(0.8)
                    
                    Text("loading...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color(red: 0.863, green: 0.631, blue: 0.365)) // #DCA15D Brown
                }
                .padding(.bottom, 50)
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
