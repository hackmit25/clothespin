
import Foundation
import SwiftUI

struct ClothingItem: Identifiable {
    let id = UUID()
    let name: String
    let category: ClothingCategory
    let brand: String?
    let color: String
    let size: String
    let lastWorn: Date?
    let wearCount: Int
    let image: String // SF Symbol name
    let notes: String?
    
    var daysSinceLastWorn: Int? {
        guard let lastWorn = lastWorn else { return nil }
        return Calendar.current.dateComponents([.day], from: lastWorn, to: Date()).day
    }
    
    var wearStatus: WearStatus {
        guard let days = daysSinceLastWorn else { return .neverWorn }
        
        if days <= 7 {
            return .recentlyWorn
        } else if days <= 30 {
            return .moderatelyWorn
        } else {
            return .rarelyWorn
        }
    }
}

enum ClothingCategory: String, CaseIterable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case dresses = "Dresses"
    case shoes = "Shoes"
    case accessories = "Accessories"
    
    var icon: String {
        switch self {
        case .tops: return "tshirt.fill"
        case .bottoms: return "figure.walk"
        case .dresses: return "figure.dress.line.vertical.figure"
        case .shoes: return "shoe.2.fill"
        case .accessories: return "bag.fill"
        }
    }
}

enum WearStatus {
    case recentlyWorn
    case moderatelyWorn
    case rarelyWorn
    case neverWorn
    
    var color: Color {
        switch self {
        case .recentlyWorn: return .green
        case .moderatelyWorn: return .orange
        case .rarelyWorn: return .red
        case .neverWorn: return .gray
        }
    }
    
    var text: String {
        switch self {
        case .recentlyWorn: return "Recently worn"
        case .moderatelyWorn: return "Moderately worn"
        case .rarelyWorn: return "Rarely worn"
        case .neverWorn: return "Never worn"
        }
    }
}

// Mock data for demonstration
extension ClothingItem {
    static let mockItems: [ClothingItem] = [
        // Tops
        ClothingItem(
            name: "White Cotton T-Shirt",
            category: .tops,
            brand: "Everlane",
            color: "White",
            size: "M",
            lastWorn: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            wearCount: 15,
            image: "tshirt.fill",
            notes: "Basic staple"
        ),
        ClothingItem(
            name: "Blue Denim Jacket",
            category: .tops,
            brand: "Levi's",
            color: "Blue",
            size: "L",
            lastWorn: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            wearCount: 8,
            image: "tshirt.fill",
            notes: "Perfect for layering"
        ),
        ClothingItem(
            name: "Black Sweater",
            category: .tops,
            brand: "Uniqlo",
            color: "Black",
            size: "M",
            lastWorn: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
            wearCount: 12,
            image: "tshirt.fill",
            notes: "Cozy winter piece"
        ),
        ClothingItem(
            name: "Striped Long Sleeve",
            category: .tops,
            brand: "H&M",
            color: "Navy/White",
            size: "S",
            lastWorn: nil,
            wearCount: 0,
            image: "tshirt.fill",
            notes: "New purchase, haven't worn yet"
        ),
        
        // Bottoms
        ClothingItem(
            name: "High-Waisted Jeans",
            category: .bottoms,
            brand: "Madewell",
            color: "Light Blue",
            size: "28",
            lastWorn: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            wearCount: 25,
            image: "figure.walk",
            notes: "Go-to jeans"
        ),
        ClothingItem(
            name: "Black Leggings",
            category: .bottoms,
            brand: "Lululemon",
            color: "Black",
            size: "M",
            lastWorn: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            wearCount: 18,
            image: "figure.walk",
            notes: "Workout essential"
        ),
        ClothingItem(
            name: "Pleated Skirt",
            category: .bottoms,
            brand: "Zara",
            color: "Beige",
            size: "S",
            lastWorn: Calendar.current.date(byAdding: .day, value: -45, to: Date()),
            wearCount: 3,
            image: "figure.walk",
            notes: "Summer piece"
        ),
        
        // Dresses
        ClothingItem(
            name: "Little Black Dress",
            category: .dresses,
            brand: "Reformation",
            color: "Black",
            size: "S",
            lastWorn: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            wearCount: 6,
            image: "figure.dress.line.vertical.figure",
            notes: "Perfect for events"
        ),
        ClothingItem(
            name: "Floral Maxi Dress",
            category: .dresses,
            brand: "Free People",
            color: "Floral",
            size: "M",
            lastWorn: Calendar.current.date(byAdding: .day, value: -20, to: Date()),
            wearCount: 4,
            image: "figure.dress.line.vertical.figure",
            notes: "Spring favorite"
        ),
        ClothingItem(
            name: "Wrap Dress",
            category: .dresses,
            brand: "Anthropologie",
            color: "Navy",
            size: "M",
            lastWorn: Calendar.current.date(byAdding: .day, value: -60, to: Date()),
            wearCount: 2,
            image: "figure.dress.line.vertical.figure",
            notes: "Office appropriate"
        ),
        
        // Shoes
        ClothingItem(
            name: "White Sneakers",
            category: .shoes,
            brand: "Converse",
            color: "White",
            size: "8",
            lastWorn: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            wearCount: 30,
            image: "shoe.2.fill",
            notes: "Everyday shoes"
        ),
        ClothingItem(
            name: "Black Ankle Boots",
            category: .shoes,
            brand: "Dr. Martens",
            color: "Black",
            size: "8",
            lastWorn: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
            wearCount: 12,
            image: "shoe.2.fill",
            notes: "Fall/winter boots"
        ),
        ClothingItem(
            name: "Red Heels",
            category: .shoes,
            brand: "Steve Madden",
            color: "Red",
            size: "8.5",
            lastWorn: Calendar.current.date(byAdding: .day, value: -90, to: Date()),
            wearCount: 1,
            image: "shoe.2.fill",
            notes: "Special occasions only"
        ),
        
        // Accessories
        ClothingItem(
            name: "Leather Handbag",
            category: .accessories,
            brand: "Coach",
            color: "Brown",
            size: "One Size",
            lastWorn: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
            wearCount: 20,
            image: "bag.fill",
            notes: "Daily bag"
        ),
        ClothingItem(
            name: "Gold Necklace",
            category: .accessories,
            brand: "Mejuri",
            color: "Gold",
            size: "One Size",
            lastWorn: Calendar.current.date(byAdding: .day, value: -15, to: Date()),
            wearCount: 8,
            image: "bag.fill",
            notes: "Delicate chain"
        ),
        ClothingItem(
            name: "Silk Scarf",
            category: .accessories,
            brand: "Hermès",
            color: "Multi-color",
            size: "One Size",
            lastWorn: Calendar.current.date(byAdding: .day, value: -120, to: Date()),
            wearCount: 2,
            image: "bag.fill",
            notes: "Investment piece"
        )
    ]
}
