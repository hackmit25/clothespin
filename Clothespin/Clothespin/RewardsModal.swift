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
                        
                        Text("\(pointsManager.totalPoints)")
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
                        Text("Available Rewards")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(pointsManager.availableRewards) { reward in
                                RewardCard(reward: reward, pointsManager: pointsManager)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Unlocked Rewards
                    if !pointsManager.unlockedRewards.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Rewards")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(pointsManager.unlockedRewards) { reward in
                                    UnlockedRewardCard(reward: reward)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Points History
                    if !pointsManager.pointsHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.title2)
                                .fontWeight(.bold)
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
            .navigationTitle("Rewards")
            .navigationBarTitleDisplayMode(.inline)
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
                .foregroundColor(reward.type.color)
                .frame(width: 40, height: 40)
                .background(reward.type.color.opacity(0.1))
                .cornerRadius(20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(reward.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                if let shopName = reward.shopName {
                    Text(shopName)
                        .font(.caption)
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
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if pointsManager.canUnlockReward(reward) {
                    Button("Claim") {
                        pointsManager.unlockReward(reward)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
                } else {
                    Text("Locked")
                        .font(.caption)
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
                Text(reward.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(reward.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                if let shopName = reward.shopName {
                    Text(shopName)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let validUntil = reward.validUntil {
                    Text("Valid until \(validUntil, style: .date)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("Unlocked")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
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
