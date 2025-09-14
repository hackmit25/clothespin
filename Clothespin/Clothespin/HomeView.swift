import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var showingProfileModal = false
    @State private var showingRewardsModal = false
    @StateObject private var pointsManager = PointsManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Submit Outfit Button - matching design style
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
                        .background(Color.primary) // Dark olive green
                        .cornerRadius(25) // More rounded like the design
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Gain Extra Points Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wear It Again")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                               VStack(spacing: 8) {
                                   RarelyWornItemCard(
                                       name: "Striped Long Sleeve",
                                       category: "Tops",
                                       wearCount: 0,
                                       icon: "tshirt.fill",
                                       selectedTab: $selectedTab,
                                       pointsManager: pointsManager
                                   )
                                   RarelyWornItemCard(
                                       name: "Red Heels",
                                       category: "Shoes",
                                       wearCount: 1,
                                       icon: "shoe.2.fill",
                                       selectedTab: $selectedTab,
                                       pointsManager: pointsManager
                                   )
                                   RarelyWornItemCard(
                                       name: "Silk Scarf",
                                       category: "Accessories",
                                       wearCount: 2,
                                       icon: "bag.fill",
                                       selectedTab: $selectedTab,
                                       pointsManager: pointsManager
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    // Points Display
                    Button(action: {
                        showingRewardsModal = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                            
                            Text("\(pointsManager.totalPoints)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.background)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Profile Button
                    Button(action: {
                        showingProfileModal = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingProfileModal) {
            ProfileModal()
        }
        .sheet(isPresented: $showingRewardsModal) {
            RewardsModal(pointsManager: pointsManager, isPresented: $showingRewardsModal)
        }
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
    @Binding var selectedTab: Int
    @ObservedObject var pointsManager: PointsManager
    
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
                
                // Points indicator
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("+10 pts")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Button("Wear Today") {
                // Award points for wearing rare item
                pointsManager.addWearRareItemPoints(itemName: name)
                selectedTab = 2 // Navigate to Add Outfit tab
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accent) // Warm brown
            .cornerRadius(20) // More rounded like the design
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct ProfileModal: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.primary)
                        
                        Text("Elaine")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Fashion Sustainability Enthusiast")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Stats Cards
                    VStack(spacing: 16) {
                        Text("Your Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            HomeStatCard(title: "Items in Closet", value: "16", icon: "tshirt.fill")
                            HomeStatCard(title: "Worn This Week", value: "4", icon: "calendar")
                            HomeStatCard(title: "Items to Donate", value: "3", icon: "heart.fill")
                            HomeStatCard(title: "Sustainability Score", value: "85%", icon: "leaf.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Insights Section
                    VStack(spacing: 16) {
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            AchievementRow(
                                icon: "leaf.fill",
                                title: "Eco Warrior",
                                description: "Maintained 85% sustainability score",
                                isUnlocked: true
                            )
                            
                            AchievementRow(
                                icon: "heart.fill",
                                title: "Giving Spirit",
                                description: "Donated 3 items this month",
                                isUnlocked: true
                            )
                            
                            AchievementRow(
                                icon: "clock.fill",
                                title: "Consistent Wardrobe",
                                description: "Worn 4 items this week",
                                isUnlocked: true
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Modal will be dismissed automatically
                    }
                }
            }
        }
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .primary : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .textPrimary : .gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
    }
}
