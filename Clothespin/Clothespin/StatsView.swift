import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatsStatCard(
                            title: "Total Items",
                            value: "0",
                            icon: "tshirt.fill",
                            color: .blue
                        )
                        
                        StatsStatCard(
                            title: "Items Worn",
                            value: "0",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatsStatCard(
                            title: "Unworn Items",
                            value: "0",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                        
                        StatsStatCard(
                            title: "Donation Score",
                            value: "0%",
                            icon: "heart.fill",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                    
                    // Sustainability Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sustainability Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        InsightCard(
                            icon: "leaf.fill",
                            title: "Environmental Impact",
                            description: "Track your fashion footprint and make more sustainable choices.",
                            value: "Start adding items to see insights"
                        )
                        
                        InsightCard(
                            icon: "clock.fill",
                            title: "Wear Frequency",
                            description: "Items worn less than 10 times in 6 months are good candidates for donation.",
                            value: "No data yet"
                        )
                        
                        InsightCard(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Circular Fashion",
                            description: "Extend the life of your clothes through donation and sustainable practices.",
                            value: "0 items donated"
                        )
                    }
                    
                    // Weekly Activity Chart (Placeholder)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Text("No activity data yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Rectangle()
                                .fill(Color(.systemGray6))
                                .frame(height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    VStack {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("Chart will appear here")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        RecommendationCard(
                            icon: "plus.circle.fill",
                            title: "Add Items to Your Closet",
                            description: "Start by adding 5-10 items to get meaningful insights about your wardrobe habits."
                        )
                        
                        RecommendationCard(
                            icon: "calendar.badge.clock",
                            title: "Track Your Wearing",
                            description: "Mark items as worn each time you wear them to build accurate usage data."
                        )
                        
                        RecommendationCard(
                            icon: "heart.fill",
                            title: "Consider Donating",
                            description: "Items you haven't worn in 3+ months might be better donated to someone who will use them."
                        )
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("Stats & Insights")
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
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
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
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
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
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
