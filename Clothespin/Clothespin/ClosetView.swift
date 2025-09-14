import SwiftUI

struct ClosetView: View {
    @ObservedObject var itemManager: ClothingItemManager
    @State private var selectedCategory = "all"
    @State private var selectedItem: ClothingItem? = nil
    @State private var showingImageModal = false
    let categories = ["all", "tops", "bottoms", "dresses", "shoes", "accessories"]
    
    // Mock data for demonstration
    private let allItems = ClothingItem.mockItems
    
    private var filteredItems: [ClothingItem] {
        return itemManager.getItems(for: selectedCategory)
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
                        
                        Text("no items in this category")
                            .font(.custom("Poppins-SemiBold", size: 22))
                            .foregroundColor(.textPrimary)
                        
                        Text("add items to your closet to start tracking your wardrobe")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: AddItemView(itemManager: itemManager, selectedTab: .constant(2))) {
                            Text("add first item")
                                .font(.custom("Poppins-SemiBold", size: 18))
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
                                ClothingItemCard(item: item) {
                                    selectedItem = item
                                    showingImageModal = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("closet")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImageModal) {
                if let item = selectedItem {
                    ImageModalView(item: item)
                }
            }
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
                .font(.custom("Poppins-Medium", size: 16))
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
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Animated thumbnail - always show category icon with animation
                Rectangle()
                    .fill(Color.background)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text(item.color)
                                .font(.custom("Poppins-Regular", size: 10))
                                .foregroundColor(.textSecondary)
                        }
                    )
                    .overlay(
                        // Subtle shimmer effect
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(45))
                            .offset(x: isAnimating ? 100 : -100)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                    )
                    .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.custom("Poppins-Medium", size: 16))
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
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    
                    // Wear count
                    Text("Worn \(item.wearCount) times")
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        }
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

struct ImageModalView: View {
    let item: ClothingItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Full-size image display
                    if let actualImage = item.actualImage {
                        Image(uiImage: actualImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .clipped()
                            .shadow(radius: 10)
                            .frame(maxHeight: 400)
                    } else {
                        // Fallback if no image
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .aspectRatio(4/3, contentMode: .fit)
                            .cornerRadius(12)
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: item.category.icon)
                                        .font(.system(size: 60))
                                        .foregroundColor(.blue)
                                    
                                    Text("No Image Available")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            )
                            .frame(maxHeight: 300)
                    }
                    
                    // Item details
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let brand = item.brand {
                            Text(brand)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Category:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(item.category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Color:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(item.color)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Size:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(item.size)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        // Wear status
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.wearStatus.color)
                                .frame(width: 12, height: 12)
                            
                            Text(item.wearStatus.text)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Worn \(item.wearCount) times")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ClosetView_Previews: PreviewProvider {
    static var previews: some View {
        ClosetView(itemManager: ClothingItemManager())
    }
}
