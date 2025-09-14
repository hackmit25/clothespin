import SwiftUI

struct RewardsModal: View {
    @ObservedObject var pointsManager: PointsManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Points Header
                    VStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("1,250")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Total Points")
                            .font(.title2)
                            .foregroundColor(.textSecondary)
                        
                        if let nextReward = pointsManager.getNextReward() {
                            VStack(spacing: 8) {
                                Text("Next Reward")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                
                                Text("\(pointsManager.getPointsToNextReward()) points to go!")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.background)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Available Rewards
                    VStack(alignment: .leading, spacing: 16) {
                        Text("available rewards")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVStack(spacing: 12) {
                            // Show first 2 rewards as unlocked
                            ForEach(Array(pointsManager.availableRewards.prefix(2).enumerated()), id: \.element.id) { index, reward in
                                UnlockedRewardCard(reward: reward)
                            }
                            
                            // Show remaining rewards as locked
                            ForEach(Array(pointsManager.availableRewards.dropFirst(2).enumerated()), id: \.element.id) { index, reward in
                                RewardCard(reward: reward, pointsManager: pointsManager)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // Points History
                    if !pointsManager.pointsHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("recent activity")
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(pointsManager.pointsHistory.prefix(10)) { activity in
                                    PointsActivityRow(activity: activity)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("rewards")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.titleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    @ObservedObject var pointsManager: PointsManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: reward.type.icon)
                .font(.title2)
                .foregroundColor(.gray)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title.lowercased())
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Text(reward.description.lowercased())
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                if let shopName = reward.shopName {
                    Text(shopName.lowercased())
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Points and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(reward.pointsRequired) pts")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.primary)
                
                if pointsManager.canUnlockReward(reward) {
                    Button("claim") {
                        pointsManager.unlockReward(reward)
                    }
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
                } else {
                    Text("locked")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(reward.isUnlocked ? Color.green : Color.border, lineWidth: 1)
        )
    }
}

struct UnlockedRewardCard: View {
    let reward: Reward
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: reward.type.icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title.lowercased())
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Text(reward.description.lowercased())
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                if let shopName = reward.shopName {
                    Text(shopName.lowercased())
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let validUntil = reward.validUntil {
                    Text("valid until \(validUntil, style: .date)")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("unlocked")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 1)
        )
    }
}

struct PointsActivityRow: View {
    let activity: PointsActivity
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: activity.type.icon)
                .font(.subheadline)
                .foregroundColor(activity.type.color)
                .frame(width: 24, height: 24)
                .background(activity.type.color.opacity(0.1))
                .cornerRadius(12)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                if let itemName = activity.itemName {
                    Text(itemName)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Points
            Text("+\(activity.points)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.background)
        .cornerRadius(8)
    }
}

struct RewardsModal_Previews: PreviewProvider {
    static var previews: some View {
        RewardsModal(pointsManager: PointsManager(), isPresented: .constant(true))
    }
}
