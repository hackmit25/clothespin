import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var showingProfileModal = false
    @State private var showingRewardsModal = false
    @StateObject private var pointsManager = PointsManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // TOP: Outfit of the Day (Primary Action)
                    VStack(spacing: 16) {
                        Text("1. catalog your closet")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            selectedTab = 2 // Navigate to Add Outfit tab
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("add your outfit of the day!")
                                    .font(.custom("Poppins-SemiBold", size: 18))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.373, green: 0.424, blue: 0.216)) // #5F6C37
                            .cornerRadius(50)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MIDDLE: News Feed with Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("2. track your wardrobe")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Tracking highlights with quick actions
                        VStack(spacing: 12) {
                            // Good news - leads to insights
                            TrackingHighlightCard(
                                type: .good,
                                title: "great rotation!",
                                message: "you've worn your black jeans 15 times this month",
                                actionText: "view insights",
                                itemImage: "img_001",
                                action: { selectedTab = 3 } // Navigate to Stats/Insights tab
                            )
                            
                            
                            // Closet audit - leads to closet sorted by least worn
                            TrackingHighlightCard(
                                type: .audit,
                                title: "closet audit needed",
                                message: "5 items haven't been worn in 30+ days",
                                actionText: "review closet",
                                itemImage: "img_012",
                                action: { 
                                    selectedTab = 1 // Navigate to Closet tab
                                    // TODO: Set sort to "least recent" when we implement that
                                }
                            )
                            
                            // View insights text link
                            Button(action: {
                                selectedTab = 3 // Navigate to Stats/Insights tab
                            }) {
                                HStack(spacing: 8) {
                                    Text("view more stats and analytics")
                                        .font(.custom("Poppins-Medium", size: 14))
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // BOTTOM: Quick Access to Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3. rewear or donate")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Haven't worn - leads to donate
                            TrackingHighlightCard(
                                type: .bad,
                                title: "time to donate",
                                message: "your red dress hasn't been worn in 45 days",
                                actionText: "donate now",
                                itemImage: "img_005",
                                action: { selectedTab = 4 } // Navigate to Donate tab
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for tab bar
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

// MARK: - News Item Card

enum NewsItemType {
    case good, bad, audit
}

struct NewsItemCard: View {
    let type: NewsItemType
    let title: String
    let message: String
    let actionText: String
    let itemImage: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Item image
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 80)
                .cornerRadius(8)
                .overlay(
                    Group {
                        if let image = UIImage(named: itemImage) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "tshirt")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                )
                .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Action button
                Button(action: {
                    // Handle action based on type
                    if type == .bad {
                        // Navigate to closet or donation
                    } else {
                        // Show encouragement or stats
                    }
                }) {
                    Text(actionText)
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(type == .good ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(type == .good ? Color.green : Color(.systemGray5))
                        .cornerRadius(16)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var borderColor: Color {
        switch type {
        case .good:
            return Color.green.opacity(0.3)
        case .bad:
            return Color.orange.opacity(0.3)
        case .audit:
            return Color.blue.opacity(0.3)
        }
    }
}

// MARK: - Tracking Highlight Card

struct TrackingHighlightCard: View {
    let type: NewsItemType
    let title: String
    let message: String
    let actionText: String
    let itemImage: String
    let action: () -> Void
    @State private var loadedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 12) {
            // Image and text content
            HStack(spacing: 12) {
                // Square image on left
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if let image = loadedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "tshirt")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                            }
                        }
                    )
                    .clipped()
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    // Main announcement - matching app style
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Subtitle
                    Text(message)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // Action button at bottom - full width
            Button(action: action) {
                Text(actionText)
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(buttonColor)
                    .cornerRadius(50)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let image = UIImage(named: itemImage) {
            loadedImage = image
        }
    }
    
    private var buttonColor: Color {
        switch type {
        case .good:
            return Color(red: 0.737, green: 0.424, blue: 0.145) // #BC6C25
        case .bad:
            return Color(red: 0.737, green: 0.424, blue: 0.145) // #BC6C25
        case .audit:
            return Color(red: 0.737, green: 0.424, blue: 0.145) // #BC6C25
        }
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
