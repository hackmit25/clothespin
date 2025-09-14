import Foundation
import SwiftUI

struct ClothingDatabase: Codable {
    let clothingItems: [ClothingItem]
    
    enum CodingKeys: String, CodingKey {
        case clothingItems = "clothing_items"
    }
}

class ClothingItemManager: ObservableObject {
    @Published var items: [ClothingItem] = []
    
    init() {
        createTestData()
    }
    
    private func createTestData() {
        // Helper function to create dates
        let calendar = Calendar.current
        let today = Date()
        
        // Helper function to create wear history
        func createWearHistory(days: [Int]) -> [Date] {
            return days.map { calendar.date(byAdding: .day, value: -$0, to: today)! }
        }
        
        let testItems = [
            // MOST WORN ITEMS (15-20 wears)
            ClothingItem(
                id: "img_001",
                name: "baggy cargo pants",
                category: .bottoms,
                brand: "abercrombie",
                color: "brown",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -8, to: today),
                notes: "perfect for streetwear",
                wearHistory: createWearHistory(days: [1, 7, 10, 14, 18, 22, 25, 28, 32, 35, 38, 42, 45, 48, 52, 55, 58, 62, 65])
            ),
            ClothingItem(
                id: "img_006",
                name: "brown cross-body bag",
                category: .accessories,
                brand: "goodwill",
                color: "brown",
                size: "one size",
                dateBought: calendar.date(byAdding: .month, value: -12, to: today),
                notes: "classic purse, perfect for everyday use",
                wearHistory: createWearHistory(days: [2, 4, 6, 8, 11, 13, 15, 17, 19, 21, 24, 26, 29, 31, 33, 36, 38, 40, 43, 45, 47, 50, 52, 55, 57, 60, 62, 67, 70, 102, 104, 106, 108, 121, 129, 138, 147, 150, 152, 162, 202, 208, 212, 224, 258, 267, 270])
            ),
            ClothingItem(
                id: "img_007",
                name: "brown cargo skirt",
                category: .bottoms,
                brand: "old navy",
                color: "brown",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -3, to: today),
                notes: "versatile mini skirt, great for work or casual",
                wearHistory: createWearHistory(days: [2, 6, 9, 12, 15, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60])
            ),
            ClothingItem(
                id: "img_010",
                name: "flare jeans",
                category: .bottoms,
                brand: "express",
                color: "blue",
                size: "28",
                dateBought: calendar.date(byAdding: .month, value: -10, to: today),
                notes: "vintage inspired, perfect fit, can wear to work",
                wearHistory: createWearHistory(days: [8, 11, 14, 17, 20, 23, 26, 29, 32, 35, 38, 41, 102, 105, 108, 111, 114, 117, 120, 123, 126, 129, 132, 135, 138, 141, 144, 147, 150, 153, 156, 159])
            ),
            ClothingItem(
                id: "img_013",
                name: "wide leg blue jeans",
                category: .bottoms,
                brand: "levi's",
                color: "medium wash",
                size: "6",
                dateBought: calendar.date(byAdding: .month, value: -9, to: today),
                notes: "straight leg, everyday staple",
                wearHistory: createWearHistory(days: [4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 46, 49, 52, 55, 58, 100, 103, 106, 109, 112, 115, 118, 121, 124, 127, 130, 133, 136, 145, 148, 151, 154, 157])
            ),
            
            // MODERATE WEARS (8-12 wears) - Seasonal patterns
            ClothingItem(
                id: "img_002",
                name: "black moto boots",
                category: .shoes,
                brand: "everlane",
                color: "black",
                size: "10",
                dateBought: calendar.date(byAdding: .month, value: -8, to: today),
                notes: "great for going out",
                wearHistory: createWearHistory(days: [3, 8, 15, 25, 35, 45, 60, 75, 90, 120, 150, 180]) // Fall/winter focused
            ),
            ClothingItem(
                id: "img_003",
                name: "black striped miniskirt",
                category: .bottoms,
                brand: "zara",
                color: "black",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -2, to: today),
                notes: "investment piece, timeless style",
                wearHistory: createWearHistory(days: [3, 5, 12, 16, 20, 30, 45]) // Spring/summer focused
            ),
            ClothingItem(
                id: "img_004",
                name: "blue cardigan",
                category: .tops,
                brand: "madewell",
                color: "navy blue",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -10, to: today),
                notes: "cozy and warm, layer for cold weather",
                wearHistory: createWearHistory(days: [100, 120, 150, 153, 145, 160, 180, 210]) // Winter/fall focused
            ),
            ClothingItem(
                id: "img_008",
                name: "brown striped sweater",
                category: .tops,
                brand: "h&m",
                color: "brown",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -9, to: today),
                notes: "cashmere blend, cozy knit sweater, perfect for layering",
                wearHistory: createWearHistory(days: [90, 110, 135, 158, 160, 172, 185, 190]) // Winter focused
            ),
            ClothingItem(
                id: "img_011",
                name: "flowy purple top",
                category: .tops,
                brand: "free people",
                color: "purple",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -4, to: today),
                notes: "bohemian style, great for summer",
                wearHistory: createWearHistory(days: [15, 25, 40, 55, 58, 69]) // Summer focused
            ),
            ClothingItem(
                id: "img_014",
                name: "purple patterned sweater",
                category: .tops,
                brand: "vintage",
                color: "purple",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -7, to: today),
                notes: "soft and cozy winter essential",
                wearHistory: createWearHistory(days: [85, 105, 126, 130, 155, 180, 192, 205, 232]) // Winter focused
            ),
            ClothingItem(
                id: "img_015",
                name: "red purse",
                category: .accessories,
                brand: "kate spade",
                color: "red",
                size: "one size",
                dateBought: calendar.date(byAdding: .month, value: -5, to: today),
                notes: "perfect pop of color, great for special occasions",
                wearHistory: createWearHistory(days: [7, 16, 25, 38, 52, 68, 85, 105, 125, 150, 175, 200]) // Special occasions
            ),
            ClothingItem(
                id: "img_017",
                name: "shiny dress",
                category: .dresses,
                brand: "asos",
                color: "silver blue",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -3, to: today),
                notes: "perfect for parties and events",
                wearHistory: createWearHistory(days: [30, 62, 65]) // Party/event focused
            ),
            ClothingItem(
                id: "img_018",
                name: "white button down long sleeve",
                category: .tops,
                brand: "everlane",
                color: "white",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -6, to: today),
                notes: "clean and elegaant, good for work or date night",
                wearHistory: createWearHistory(days: [45, 60, 100, 125, 150, 158, 174, 210]) // Work/formal occasions
            ),
            ClothingItem(
                id: "img_019",
                name: "white and gold flower dress",
                category: .dresses,
                brand: "pacsun",
                color: "white",
                size: "S",
                dateBought: calendar.date(byAdding: .month, value: -5, to: today),
                notes: "worn for graduation, summer dress, perfect for warm weather",
                wearHistory: createWearHistory(days: [200, 230]) // Summer/formal events
            ),
            
            // FEW WEARS
            ClothingItem(
                id: "img_012",
                name: "ripped jean shorts",
                category: .bottoms,
                brand: "hollister",
                color: "medium wash",
                size: "27",
                dateBought: calendar.date(byAdding: .month, value: -3, to: today),
                notes: "summer essential, a bit short",
                wearHistory: createWearHistory(days: [45, 80, 150, 165, 182, 190]) // Summer only, spread out
            ),
            ClothingItem(
                id: "img_016",
                name: "red tank top",
                category: .tops,
                brand: "express",
                color: "red",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -2, to: today),
                notes: "semi professional, great for work outfits",
                wearHistory: createWearHistory(days: [16, 35, 60, 170, 185, 208]) // Work appropriate, occasional use
            ),
            ClothingItem(
                id: "img_005",
                name: "blue flower dress",
                category: .dresses,
                brand: "forever 21",
                color: "blue",
                size: "4",
                dateBought: calendar.date(byAdding: .month, value: -8, to: today),
                notes: "perfect for summer weddings, parties, etc.",
                wearHistory: createWearHistory(days: [15, 45, 90, 150, 220]) // Very spread out, special occasions
            ),

            // NO WEARS
            ClothingItem(
                id: "img_009",
                name: "colorful jacket",
                category: .tops,
                brand: "vintage",
                color: "multicolor",
                size: "M",
                dateBought: calendar.date(byAdding: .month, value: -2, to: today),
                notes: "statement piece, great for layering",
                wearHistory: []
            )
        ]
        
        self.items = testItems
    }
    
    
    func addItem(name: String, category: String, image: UIImage) {
        // Convert category string to ClothingCategory enum
        guard let clothingCategory = ClothingCategory(rawValue: category) else { return }
        
        // Generate a new ID
        let newId = "img_\(String(format: "%03d", items.count + 1))"
        
        // Create a new clothing item
        let newItem = ClothingItem(
            id: newId,
            name: name,
            category: clothingCategory,
            brand: nil,
            color: "Unknown", // We could add color detection later
            size: "Unknown", // We could add size input later
            dateBought: Date(), // Set purchase date to today
            notes: nil,
            wearHistory: [] // Start with empty wear history
        )
        
        // Add the item to the beginning of the list (most recent first)
        items.insert(newItem, at: 0)
        
        // Save to database
        saveItems()
    }
    
    func recordWear(for itemId: String) {
        // Find the item and add today's date to its wear history
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = items[index]
            updatedItem.wearHistory.append(Date())
            items[index] = updatedItem
            
            // Save to database
            saveItems()
        }
    }
    
    func getItems(for category: String) -> [ClothingItem] {
        if category.lowercased() == "all" {
            return items
        } else {
            return items.filter { $0.category.rawValue.lowercased() == category.lowercased() }
        }
    }
    
    private func saveItems() {
        let database = ClothingDatabase(clothingItems: items)
        
        guard let url = Bundle.main.url(forResource: "clothing_database", withExtension: "json") else {
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(database)
            try data.write(to: url)
        } catch {
            // Silent fail
        }
    }
    
    func deleteItem(_ item: ClothingItem) {
        items.removeAll { $0.id == item.id }
    }

}
