import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Sustainability Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sustainability Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        InsightCard(
                            icon: "leaf.fill",
                            title: "Environmental Impact",
                            description: "Your wardrobe shows good sustainability practices with 85% of items being actively used.",
                            value: "85% utilization rate"
                        )
                        
                        InsightCard(
                            icon: "clock.fill",
                            title: "Wear Frequency",
                            description: "3 items worn less than 3 times are candidates for donation (Red Heels, Pleated Skirt, Striped Long Sleeve).",
                            value: "3 low-use items"
                        )
                        
                        InsightCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Circular Fashion",
                            description: "Ready to donate 3 items to extend their life cycle and reduce waste.",
                            value: "3 items ready"
                        )
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        RecommendationCard(
                            icon: "heart.fill",
                            title: "Donate Low-Use Items",
                            description: "Consider donating your Red Heels (worn 1x), Pleated Skirt (worn 3x), and Striped Long Sleeve (never worn)."
                        )
                        
                        RecommendationCard(
                            icon: "tshirt.fill",
                            title: "Your Most Worn Items",
                            description: "White Sneakers (30 wears) and High-Waisted Jeans (25 wears) are your wardrobe heroes!"
                        )
                        
                        RecommendationCard(
                            icon: "leaf.fill",
                            title: "Great Sustainability",
                            description: "You're doing well with an 85% utilization rate. Keep up the sustainable fashion practices!"
                        )
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
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
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Text(description)
                .font(.subheadline)
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
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
