import Foundation
import SwiftUI

// Your personal clothing items with images
extension ClothingItem {
    static let myItems: [ClothingItem] = [
        // Example items - replace these with your actual clothing items
        ClothingItem(
            name: "vintage denim jacket",
            category: .tops,
            brand: "levi's",
            color: "light blue",
            size: "M",
            dateBought: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            image: "img_001", // Your PNG image name
            actualImage: nil,
            notes: "perfect for layering, goes with everything",
            wearHistory: generateWearHistory(days: [-3, -7, -12, -18, -25, -32, -40, -45, -52, -60, -68, -75])
        ),
        ClothingItem(
            name: "white linen shirt",
            category: .tops,
            brand: "everlane",
            color: "white",
            size: "S",
            dateBought: Calendar.current.date(byAdding: .month, value: -2, to: Date()),
            image: "img_002", // Your PNG image name
            actualImage: nil,
            notes: "summer essential, breathable fabric",
            wearHistory: generateWearHistory(days: [-1, -4, -8, -15, -22, -29, -36, -43])
        ),
        ClothingItem(
            name: "black leather jacket",
            category: .tops,
            brand: "all saints",
            color: "black",
            size: "M",
            dateBought: Calendar.current.date(byAdding: .month, value: -12, to: Date()),
            image: "img_003", // Your PNG image name
            actualImage: nil,
            notes: "investment piece, timeless style",
            wearHistory: generateWearHistory(days: [-5, -10, -18, -25, -35, -42, -50, -58, -65, -72, -80, -88, -95, -102, -110])
        ),
        ClothingItem(
            name: "high-waisted jeans",
            category: .bottoms,
            brand: "madewell",
            color: "medium wash",
            size: "28",
            dateBought: Calendar.current.date(byAdding: .month, value: -8, to: Date()),
            image: "img_004", // Your PNG image name
            actualImage: nil,
            notes: "most comfortable jeans, perfect fit",
            wearHistory: generateWearHistory(days: [-2, -5, -9, -14, -20, -27, -34, -41, -48, -55, -62, -69, -76, -83, -90, -97, -104, -111, -118, -125])
        ),
        ClothingItem(
            name: "white sneakers",
            category: .shoes,
            brand: "converse",
            color: "white",
            size: "8",
            dateBought: Calendar.current.date(byAdding: .month, value: -4, to: Date()),
            image: "img_005", // Your PNG image name
            actualImage: nil,
            notes: "daily wear, goes with everything",
            wearHistory: generateWearHistory(days: [-1, -2, -4, -6, -8, -10, -12, -14, -16, -18, -20, -22, -24, -26, -28, -30, -32, -34, -36, -38, -40, -42, -44, -46, -48, -50, -52, -54, -56, -58])
        ),
        ClothingItem(
            name: "black ankle boots",
            category: .shoes,
            brand: "dr. martens",
            color: "black",
            size: "8",
            dateBought: Calendar.current.date(byAdding: .month, value: -10, to: Date()),
            image: "img_006", // Your PNG image name
            actualImage: nil,
            notes: "fall/winter staple, comfortable for walking",
            wearHistory: generateWearHistory(days: [-6, -13, -20, -28, -35, -42, -49, -56, -63, -70, -77, -84, -91, -98, -105, -112, -119, -126, -133, -140])
        ),
        ClothingItem(
            name: "little black dress",
            category: .dresses,
            brand: "reformation",
            color: "black",
            size: "S",
            dateBought: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
            image: "img_007", // Your PNG image name
            actualImage: nil,
            notes: "perfect for events and dates",
            wearHistory: generateWearHistory(days: [-8, -15, -25, -35, -45, -55])
        ),
        ClothingItem(
            name: "leather handbag",
            category: .accessories,
            brand: "coach",
            color: "brown",
            size: "one size",
            dateBought: Calendar.current.date(byAdding: .month, value: -18, to: Date()),
            image: "img_008", // Your PNG image name
            actualImage: nil,
            notes: "daily bag, fits everything i need",
            wearHistory: generateWearHistory(days: [-1, -3, -6, -9, -12, -15, -18, -21, -24, -27, -30, -33, -36, -39, -42, -45, -48, -51, -54, -57, -60, -63, -66, -69, -72, -75, -78, -81, -84, -87, -90, -93, -96, -99, -102, -105, -108, -111, -114, -117, -120, -123, -126, -129, -132, -135, -138, -141, -144, -147, -150])
        )
    ]
}

// Helper function to generate wear history from days ago
func generateWearHistory(days: [Int]) -> [Date] {
    return days.compactMap { dayOffset in
        Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())
    }
}
