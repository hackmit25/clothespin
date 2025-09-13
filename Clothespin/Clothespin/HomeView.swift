import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    VStack(spacing: 16) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 80))
                            .foregroundColor(.primary)
                        
                        Text("welcome to clothespin!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("your fashion sustainability companion")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Submit Outfit Button
                    Button(action: {
                        selectedTab = 2 // Navigate to Add Outfit tab
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Submit Your Outfit for Today")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.primary)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Quick Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        HomeStatCard(title: "Items in Closet", value: "16", icon: "tshirt.fill")
                        HomeStatCard(title: "Worn This Week", value: "4", icon: "calendar")
                        HomeStatCard(title: "Items to Donate", value: "3", icon: "heart.fill")
                        HomeStatCard(title: "Sustainability Score", value: "85%", icon: "leaf.fill")
                    }
                    .padding(.horizontal)
                    
                    // Gain Extra Points Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gain Extra Points to Wear This Again")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            RarelyWornItemCard(
                                name: "Striped Long Sleeve",
                                category: "Tops",
                                wearCount: 0,
                                icon: "tshirt.fill"
                            )
                            RarelyWornItemCard(
                                name: "Red Heels",
                                category: "Shoes", 
                                wearCount: 1,
                                icon: "shoe.2.fill"
                            )
                            RarelyWornItemCard(
                                name: "Silk Scarf",
                                category: "Accessories",
                                wearCount: 2,
                                icon: "bag.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ActivityRow(icon: "tshirt", text: "White Cotton T-Shirt worn yesterday")
                            ActivityRow(icon: "figure.walk", text: "High-Waisted Jeans worn yesterday")
                            ActivityRow(icon: "heart.fill", text: "3 items ready for donation")
                            ActivityRow(icon: "leaf.fill", text: "Great sustainability score: 85%")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
            }
            .navigationTitle("Hello, Elaine")
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
                .foregroundColor(.primary)
            
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

struct ActivityRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct RarelyWornItemCard: View {
    let name: String
    let category: String
    let wearCount: Int
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(category)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(wearCount == 0 ? "Never worn" : "Worn \(wearCount)x")
                    .font(.caption2)
                    .foregroundColor(.accent)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button("Wear Today") {
                // TODO: Handle wear action
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accent)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
    }
}
