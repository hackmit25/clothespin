import Foundation
import SwiftUI

// MARK: - Points System Models

struct Reward: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let pointsRequired: Int
    let type: RewardType
    let isUnlocked: Bool
    let shopName: String?
    let discount: String?
    let validUntil: Date?
    
    enum RewardType: String, Codable, CaseIterable {
        case coupon = "coupon"
        case discount = "discount"
        case freeShipping = "free_shipping"
        case exclusiveAccess = "exclusive_access"
        
        var icon: String {
            switch self {
            case .coupon:
                return "ticket.fill"
            case .discount:
                return "percent"
            case .freeShipping:
                return "shippingbox.fill"
            case .exclusiveAccess:
                return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .coupon:
                return .yellow
            case .discount:
                return .green
            case .freeShipping:
                return .blue
            case .exclusiveAccess:
                return .purple
            }
        }
    }
}

struct PointsActivity: Identifiable, Codable {
    let id = UUID()
    let type: ActivityType
    let points: Int
    let description: String
    let timestamp: Date
    let itemName: String?
    
    enum ActivityType: String, Codable {
        case donation = "donation"
        case wearRareItem = "wear_rare_item"
        case weeklyStreak = "weekly_streak"
        case firstItem = "first_item"
        case milestone = "milestone"
        
        var icon: String {
            switch self {
            case .donation:
                return "heart.fill"
            case .wearRareItem:
                return "tshirt.fill"
            case .weeklyStreak:
                return "calendar"
            case .firstItem:
                return "star.fill"
            case .milestone:
                return "trophy.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .donation:
                return .red
            case .wearRareItem:
                return .orange
            case .weeklyStreak:
                return .blue
            case .firstItem:
                return .yellow
            case .milestone:
                return .purple
            }
        }
    }
}

// MARK: - Points Manager

class PointsManager: ObservableObject {
    @Published var totalPoints: Int = 0
    @Published var pointsHistory: [PointsActivity] = []
    @Published var availableRewards: [Reward] = []
    @Published var unlockedRewards: [Reward] = []
    
    private let userDefaults = UserDefaults.standard
    private let pointsKey = "totalPoints"
    private let historyKey = "pointsHistory"
    private let unlockedRewardsKey = "unlockedRewards"
    
    // Points values
    private let donationPoints = 50
    private let rareItemWearPoints = 10
    private let weeklyStreakPoints = 25
    private let firstItemPoints = 100
    private let milestonePoints = 200
    
    init() {
        loadPointsData()
        generateRewards()
    }
    
    // MARK: - Public Methods
    
    func addDonationPoints(itemCount: Int, location: String) {
        let points = donationPoints * itemCount
        let activity = PointsActivity(
            type: .donation,
            points: points,
            description: "Donated \(itemCount) item(s) to \(location)",
            timestamp: Date(),
            itemName: nil
        )
        
        addPoints(activity)
        
        // Check for milestone rewards
        checkMilestones()
    }
    
    func addWearRareItemPoints(itemName: String) {
        let activity = PointsActivity(
            type: .wearRareItem,
            points: rareItemWearPoints,
            description: "Wore rarely used item",
            timestamp: Date(),
            itemName: itemName
        )
        
        addPoints(activity)
    }
    
    func addWeeklyStreakPoints() {
        let activity = PointsActivity(
            type: .weeklyStreak,
            points: weeklyStreakPoints,
            description: "Maintained weekly wearing streak",
            timestamp: Date(),
            itemName: nil
        )
        
        addPoints(activity)
    }
    
    func addFirstItemPoints() {
        let activity = PointsActivity(
            type: .firstItem,
            points: firstItemPoints,
            description: "Added your first item to closet",
            timestamp: Date(),
            itemName: nil
        )
        
        addPoints(activity)
    }
    
    func getNextReward() -> Reward? {
        return availableRewards.first { !$0.isUnlocked }
    }
    
    func getPointsToNextReward() -> Int {
        guard let nextReward = getNextReward() else { return 0 }
        return max(0, nextReward.pointsRequired - totalPoints)
    }
    
    func canUnlockReward(_ reward: Reward) -> Bool {
        return totalPoints >= reward.pointsRequired && !reward.isUnlocked
    }
    
    func unlockReward(_ reward: Reward) {
        guard canUnlockReward(reward) else { return }
        
        var updatedReward = reward
        updatedReward = Reward(
            title: reward.title,
            description: reward.description,
            pointsRequired: reward.pointsRequired,
            type: reward.type,
            isUnlocked: true,
            shopName: reward.shopName,
            discount: reward.discount,
            validUntil: reward.validUntil
        )
        
        unlockedRewards.append(updatedReward)
        savePointsData()
    }
    
    // MARK: - Private Methods
    
    private func addPoints(_ activity: PointsActivity) {
        totalPoints += activity.points
        pointsHistory.insert(activity, at: 0)
        
        // Keep only last 50 activities
        if pointsHistory.count > 50 {
            pointsHistory = Array(pointsHistory.prefix(50))
        }
        
        savePointsData()
        
        // Check for new reward unlocks
        checkRewardUnlocks()
    }
    
    private func checkMilestones() {
        let milestones = [100, 250, 500, 1000, 1500, 2000]
        
        for milestone in milestones {
            if totalPoints >= milestone && !pointsHistory.contains(where: { 
                $0.type == .milestone && $0.points == milestonePoints 
            }) {
                let activity = PointsActivity(
                    type: .milestone,
                    points: milestonePoints,
                    description: "Reached \(milestone) points milestone!",
                    timestamp: Date(),
                    itemName: nil
                )
                
                totalPoints += milestonePoints
                pointsHistory.insert(activity, at: 0)
                savePointsData()
            }
        }
    }
    
    private func checkRewardUnlocks() {
        for reward in availableRewards {
            if canUnlockReward(reward) && !unlockedRewards.contains(where: { $0.id == reward.id }) {
                unlockReward(reward)
            }
        }
    }
    
    private func generateRewards() {
        availableRewards = [
            Reward(
                title: "10% Off Vintage Finds",
                description: "Get 10% off your next purchase at Vintage Revival",
                pointsRequired: 100,
                type: .discount,
                isUnlocked: false,
                shopName: "Vintage Revival",
                discount: "10% OFF",
                validUntil: Calendar.current.date(byAdding: .month, value: 1, to: Date())
            ),
            Reward(
                title: "Free Shipping",
                description: "Free shipping on orders over $25 at Thrift Treasure",
                pointsRequired: 200,
                type: .freeShipping,
                isUnlocked: false,
                shopName: "Thrift Treasure",
                discount: "FREE SHIPPING",
                validUntil: Calendar.current.date(byAdding: .month, value: 2, to: Date())
            ),
            Reward(
                title: "$5 Off Next Purchase",
                description: "Save $5 on your next purchase at EcoStyle Boutique",
                pointsRequired: 350,
                type: .coupon,
                isUnlocked: false,
                shopName: "EcoStyle Boutique",
                discount: "$5 OFF",
                validUntil: Calendar.current.date(byAdding: .month, value: 1, to: Date())
            ),
            Reward(
                title: "Early Access Sale",
                description: "Get early access to the monthly sale at Retro Threads",
                pointsRequired: 500,
                type: .exclusiveAccess,
                isUnlocked: false,
                shopName: "Retro Threads",
                discount: "EARLY ACCESS",
                validUntil: Calendar.current.date(byAdding: .month, value: 3, to: Date())
            ),
            Reward(
                title: "15% Off Everything",
                description: "15% off everything in store at Sustainable Style",
                pointsRequired: 750,
                type: .discount,
                isUnlocked: false,
                shopName: "Sustainable Style",
                discount: "15% OFF",
                validUntil: Calendar.current.date(byAdding: .month, value: 2, to: Date())
            ),
            Reward(
                title: "$20 Off Large Purchase",
                description: "Save $20 on purchases over $100 at Green Fashion Co",
                pointsRequired: 1000,
                type: .coupon,
                isUnlocked: false,
                shopName: "Green Fashion Co",
                discount: "$20 OFF",
                validUntil: Calendar.current.date(byAdding: .month, value: 2, to: Date())
            ),
            Reward(
                title: "VIP Shopping Experience",
                description: "Private shopping appointment at The Circular Closet",
                pointsRequired: 1500,
                type: .exclusiveAccess,
                isUnlocked: false,
                shopName: "The Circular Closet",
                discount: "VIP EXPERIENCE",
                validUntil: Calendar.current.date(byAdding: .month, value: 6, to: Date())
            ),
            Reward(
                title: "25% Off Premium Items",
                description: "25% off premium vintage and designer items at Luxe Thrift",
                pointsRequired: 2000,
                type: .discount,
                isUnlocked: false,
                shopName: "Luxe Thrift",
                discount: "25% OFF",
                validUntil: Calendar.current.date(byAdding: .month, value: 3, to: Date())
            )
        ]
        
        // Check which rewards are already unlocked
        checkRewardUnlocks()
    }
    
    // MARK: - Persistence
    
    private func savePointsData() {
        userDefaults.set(totalPoints, forKey: pointsKey)
        
        if let historyData = try? JSONEncoder().encode(pointsHistory) {
            userDefaults.set(historyData, forKey: historyKey)
        }
        
        if let unlockedData = try? JSONEncoder().encode(unlockedRewards) {
            userDefaults.set(unlockedData, forKey: unlockedRewardsKey)
        }
    }
    
    private func loadPointsData() {
        totalPoints = userDefaults.integer(forKey: pointsKey)
        
        if let historyData = userDefaults.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([PointsActivity].self, from: historyData) {
            pointsHistory = history
        }
        
        if let unlockedData = userDefaults.data(forKey: unlockedRewardsKey),
           let unlocked = try? JSONDecoder().decode([Reward].self, from: unlockedData) {
            unlockedRewards = unlocked
        }
    }
}
