import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Sustainability Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("sustainability insights")
                            .font(.custom("Poppins-Bold", size: 22))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        InsightCard(
                            icon: "leaf.fill",
                            title: "environmental impact",
                            description: "your wardrobe shows good sustainability practices with 85% of items being actively used.",
                            value: "85% utilization rate"
                        )
                        
                        InsightCard(
                            icon: "clock.fill",
                            title: "wear frequency",
                            description: "3 items worn less than 3 times are candidates for donation (red heels, pleated skirt, striped long sleeve).",
                            value: "3 low-use items"
                        )
                        
                        InsightCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "circular fashion",
                            description: "ready to donate 3 items to extend their life cycle and reduce waste.",
                            value: "3 items ready"
                        )
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("recommendations")
                            .font(.custom("Poppins-Bold", size: 22))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        RecommendationCard(
                            icon: "heart.fill",
                            title: "donate low-use items",
                            description: "consider donating your red heels (worn 1x), pleated skirt (worn 3x), and striped long sleeve (never worn)."
                        )
                        
                        RecommendationCard(
                            icon: "tshirt.fill",
                            title: "your most worn items",
                            description: "white sneakers (30 wears) and high-waisted jeans (25 wears) are your wardrobe heroes!"
                        )
                        
                        RecommendationCard(
                            icon: "leaf.fill",
                            title: "great sustainability",
                            description: "you're doing well with an 85% utilization rate. keep up the sustainable fashion practices!"
                        )
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.titleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .semibold)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct StatsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.cardBackground)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(value)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            Text(description)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct RecommendationCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
