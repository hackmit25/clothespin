import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    VStack(spacing: 16) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Welcome to Clothespin!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your fashion sustainability companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Quick Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        HomeStatCard(title: "Items in Closet", value: "0", icon: "tshirt.fill")
                        HomeStatCard(title: "Worn This Week", value: "0", icon: "calendar")
                        HomeStatCard(title: "Items to Donate", value: "0", icon: "heart.fill")
                        HomeStatCard(title: "Sustainability Score", value: "0%", icon: "leaf.fill")
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ActivityRow(icon: "plus.circle", text: "Add your first item to get started")
                            ActivityRow(icon: "tshirt", text: "Your closet is empty")
                            ActivityRow(icon: "chart.bar", text: "No stats available yet")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HomeStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
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

struct ActivityRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
