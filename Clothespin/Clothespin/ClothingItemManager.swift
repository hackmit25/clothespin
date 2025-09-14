import Foundation
import SwiftUI

class ClothingItemManager: ObservableObject {
    @Published var items: [ClothingItem] = ClothingItem.mockItems
    
    func addItem(name: String, category: String, image: UIImage) {
        // Convert category string to ClothingCategory enum
        guard let clothingCategory = ClothingCategory(rawValue: category) else { return }
        
        // Create a new clothing item
        let newItem = ClothingItem(
            name: name,
            category: clothingCategory,
            brand: nil,
            color: "Unknown", // We could add color detection later
            size: "Unknown", // We could add size input later
            lastWorn: nil,
            wearCount: 0,
            image: "photo", // SF Symbol fallback
            actualImage: image, // The actual uploaded image
            notes: nil
        )
        
        // Add the item to the beginning of the list (most recent first)
        items.insert(newItem, at: 0)
    }
    
    func getItems(for category: String) -> [ClothingItem] {
        if category == "All" {
            return items
        } else {
            return items.filter { $0.category.rawValue == category }
        }
    }
}
