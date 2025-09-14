
import Foundation
import SwiftUI

struct ClothingItem: Identifiable, Codable {
    let id: String // Use string ID from database
    let name: String
    let category: ClothingCategory
    let brand: String?
    let color: String
    let size: String
    let dateBought: Date?
    let notes: String?
    var wearHistory: [Date] // List of dates when this item was worn
    var lastWorn: Date? { wearHistory.first }
    var wearCount: Int { wearHistory.count }
    
    // Computed property for image name based on ID
    var imageName: String { id }
    
    // For user-uploaded items
    var actualImage: UIImage? { nil }
    
    // Custom coding keys to match JSON structure
    enum CodingKeys: String, CodingKey {
        case id, name, category, brand, color, size, notes
        case dateBought = "date_bought"
        case wearHistory = "wear_history"
    }
    
    // Custom init from decoder to handle date string parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(ClothingCategory.self, forKey: .category)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        color = try container.decode(String.self, forKey: .color)
        size = try container.decode(String.self, forKey: .size)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Parse date_bought from string
        if let dateString = try container.decodeIfPresent(String.self, forKey: .dateBought) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dateBought = formatter.date(from: dateString)
        } else {
            dateBought = nil
        }
        
        // Parse wear_history from string array
        let wearHistoryStrings = try container.decodeIfPresent([String].self, forKey: .wearHistory) ?? []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        wearHistory = wearHistoryStrings.compactMap { formatter.date(from: $0) }
    }
    
    // Explicit memberwise initializer for creating new items
    init(id: String, name: String, category: ClothingCategory, brand: String?, color: String, size: String, dateBought: Date?, notes: String?, wearHistory: [Date]) {
        self.id = id
        self.name = name
        self.category = category
        self.brand = brand
        self.color = color
        self.size = size
        self.dateBought = dateBought
        self.notes = notes
        self.wearHistory = wearHistory
    }
    
    // Custom encode method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encode(color, forKey: .color)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(notes, forKey: .notes)
        
        // Encode date_bought as string
        if let dateBought = dateBought {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            try container.encode(formatter.string(from: dateBought), forKey: .dateBought)
        }
        
        // Encode wear_history as string array
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let wearHistoryStrings = wearHistory.map { formatter.string(from: $0) }
        try container.encode(wearHistoryStrings, forKey: .wearHistory)
    }
    
    var daysSinceLastWorn: Int? {
        guard let lastWorn = lastWorn else { return nil }
        return Calendar.current.dateComponents([.day], from: lastWorn, to: Date()).day
    }
    
    var wearStatus: WearStatus {
        guard let days = daysSinceLastWorn else { return .neverWorn }
        
        if days <= 14 {
            return .recentlyWorn
        } else if days <= 30 {
            return .moderatelyWorn
        } else {
            return .rarelyWorn
        }
    }
}

enum ClothingCategory: String, CaseIterable, Codable {
    case tops = "tops"
    case bottoms = "bottoms"
    case dresses = "dresses"
    case shoes = "shoes"
    case accessories = "accessories"
    
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

// Helper function to generate wear history
func generateWearHistory(days: [Int]) -> [Date] {
    return days.compactMap { dayOffset in
        Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())
    }
}
