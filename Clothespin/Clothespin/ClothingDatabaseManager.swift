import Foundation
import SwiftUI

struct ClothingDatabase: Codable {
    let clothingItems: [ClothingItem]
    
    enum CodingKeys: String, CodingKey {
        case clothingItems = "clothing_items"
    }
}

class ClothingDatabaseManager: ObservableObject {
    @Published var items: [ClothingItem] = []
    
    init() {
        loadClothingItems()
    }
    
    func loadClothingItems() {
        guard let url = Bundle.main.url(forResource: "clothing_database", withExtension: "json") else {
            print("Could not find clothing_database.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            let database = try decoder.decode(ClothingDatabase.self, from: data)
            self.items = database.clothingItems
        } catch {
            print("Error loading clothing database: \(error)")
        }
    }
    
    func recordWear(for itemId: String) {
        // Find the item and add today's date to its wear history
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = items[index]
            updatedItem.wearHistory.append(Date())
            items[index] = updatedItem
            
            // Save the updated data back to the JSON file
            saveClothingItems()
        }
    }
    
    func saveClothingItems() {
        let database = ClothingDatabase(clothingItems: items)
        
        guard let url = Bundle.main.url(forResource: "clothing_database", withExtension: "json") else {
            print("Could not find clothing_database.json")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(database)
            try data.write(to: url)
        } catch {
            print("Error saving clothing database: \(error)")
        }
    }
    
    func getItems(for category: String) -> [ClothingItem] {
        if category.lowercased() == "all" {
            return items
        } else {
            return items.filter { $0.category.rawValue.lowercased() == category.lowercased() }
        }
    }
}
