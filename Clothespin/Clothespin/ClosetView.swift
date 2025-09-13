import SwiftUI

struct ClosetView: View {
    @State private var selectedCategory = "All"
    let categories = ["All", "Tops", "Bottoms", "Dresses", "Shoes", "Accessories"]
    
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
                if selectedCategory == "All" && categories.count == 6 { // Empty state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your closet is empty")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Add items to your closet to start tracking your wardrobe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: AddItemView()) {
                            Text("Add First Item")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
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
                            // Placeholder for future clothing items
                            ForEach(0..<0, id: \.self) { _ in
                                ClothingItemCard()
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
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ClothingItemCard: View {
    var body: some View {
        VStack(spacing: 8) {
            // Placeholder for clothing image
            Rectangle()
                .fill(Color(.systemGray5))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "tshirt")
                        .font(.title)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Item Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("Last worn: Never")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ClosetView_Previews: PreviewProvider {
    static var previews: some View {
        ClosetView()
    }
}
