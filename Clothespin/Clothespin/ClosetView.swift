import SwiftUI

struct ClosetView: View {
    @State private var selectedCategory = "All"
    let categories = ["All", "Tops", "Bottoms", "Dresses", "Shoes", "Accessories"]
    
    // Mock data for demonstration
    private let allItems = ClothingItem.mockItems
    
    private var filteredItems: [ClothingItem] {
        if selectedCategory == "All" {
            return allItems
        } else {
            return allItems.filter { $0.category.rawValue == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                
                // Clothing Grid
                if filteredItems.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 60))
                            .foregroundColor(.primary)
                        
                        Text("No items in this category")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                        
                        Text("Add items to your closet to start tracking your wardrobe")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: AddItemView()) {
                            Text("Add First Item")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.primary)
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredItems) { item in
                                ClothingItemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Closet")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primary : Color.cardBackground)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .cornerRadius(20)
        }
    }
}

struct ClothingItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Clothing image placeholder with category icon
            Rectangle()
                .fill(Color.background)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: item.category.icon)
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        Text(item.color)
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                if let brand = item.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                // Wear status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.wearStatus.color)
                        .frame(width: 6, height: 6)
                    
                    Text(lastWornText)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                // Wear count
                Text("Worn \(item.wearCount) times")
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
    
    private var lastWornText: String {
        if let days = item.daysSinceLastWorn {
            if days == 0 {
                return "Worn today"
            } else if days == 1 {
                return "Worn yesterday"
            } else if days < 7 {
                return "\(days) days ago"
            } else if days < 30 {
                return "\(days/7) weeks ago"
            } else {
                return "\(days/30) months ago"
            }
        } else {
            return "Never worn"
        }
    }
}

struct ClosetView_Previews: PreviewProvider {
    static var previews: some View {
        ClosetView()
    }
}
