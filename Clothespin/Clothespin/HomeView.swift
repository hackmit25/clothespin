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
                            Text("submit your outfit for today")
                                .font(.custom("Poppins-SemiBold", size: 18))
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
                        Text("wear it again")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                               VStack(spacing: 8) {
                                   RarelyWornItemCard(
                                       name: "striped long sleeve",
                                       category: "tops",
                                       wearCount: 0,
                                       icon: "tshirt.fill",
                                       selectedTab: $selectedTab,
                                       pointsManager: pointsManager
                                   )
                                   RarelyWornItemCard(
                                       name: "red heels",
                                       category: "shoes",
                                       wearCount: 1,
                                       icon: "shoe.2.fill",
                                       selectedTab: $selectedTab,
                                       pointsManager: pointsManager
                                   )
                                   RarelyWornItemCard(
                                       name: "silk scarf",
                                       category: "accessories",
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
                        Text("recent activity")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ActivityRow(icon: "tshirt", text: "white cotton t-shirt worn yesterday")
                            ActivityRow(icon: "figure.walk", text: "high-waisted jeans worn yesterday")
                            ActivityRow(icon: "heart.fill", text: "3 items ready for donation")
                            ActivityRow(icon: "leaf.fill", text: "great sustainability score: 85%")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
        }
        .navigationTitle("hello, krystal")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Points Display
                    Button(action: {
                        showingRewardsModal = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                            
                            Text("\(pointsManager.totalPoints)")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }
                    
                    // Notifications Button
                    Button(action: {
                        // TODO: Add notifications action
                    }) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
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
                .font(.custom("Poppins-Bold", size: 22))
                .fontWeight(.bold)
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

struct ActivityRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .frame(width: 20)
            
            Text(text)
                .font(.custom("Poppins-Regular", size: 16))
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
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Text(category)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.textSecondary)
                
                Text(wearCount == 0 ? "never worn" : "worn \(wearCount)x")
                    .font(.custom("Poppins-Medium", size: 10))
                    .foregroundColor(.accent)
                    .fontWeight(.medium)
                
                // Points indicator
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("+10 pts")
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Button("wear today") {
                // Award points for wearing rare item
                pointsManager.addWearRareItemPoints(itemName: name)
                selectedTab = 2 // Navigate to Add Outfit tab
            }
            .font(.custom("Poppins-Medium", size: 12))
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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.primary)
                        
                        Text("krystal")
                            .font(.custom("Poppins-Bold", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("fashion sustainability enthusiast")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Stats Cards
                    VStack(spacing: 16) {
                        Text("your stats")
                            .font(.custom("Poppins-Bold", size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            HomeStatCard(title: "items in closet", value: "16", icon: "tshirt.fill")
                            HomeStatCard(title: "worn this week", value: "4", icon: "calendar")
                            HomeStatCard(title: "items to donate", value: "3", icon: "heart.fill")
                            HomeStatCard(title: "sustainability score", value: "85%", icon: "leaf.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Insights Section
                    VStack(spacing: 16) {
                        Text("insights")
                            .font(.custom("Poppins-Bold", size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            AchievementRow(
                                icon: "leaf.fill",
                                title: "eco warrior",
                                description: "maintained 85% sustainability score",
                                isUnlocked: true
                            )
                            
                            AchievementRow(
                                icon: "heart.fill",
                                title: "giving spirit",
                                description: "donated 3 items this month",
                                isUnlocked: true
                            )
                            
                            AchievementRow(
                                icon: "clock.fill",
                                title: "consistent wardrobe",
                                description: "worn 4 items this week",
                                isUnlocked: true
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        dismiss()
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
                    .font(.custom("Poppins-Medium", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .textPrimary : .gray)
                
                Text(description)
                    .font(.custom("Poppins-Regular", size: 12))
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
