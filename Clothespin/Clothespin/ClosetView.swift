import SwiftUI

struct ClosetView: View {
    @ObservedObject var itemManager: ClothingItemManager
    @State private var selectedCategory = "all"
    @State private var selectedItem: ClothingItem? = nil
    @State private var showingImageModal = false
    @State private var sortOption: SortOption = .mostRecent
    let categories = ["all", "tops", "bottoms", "dresses", "shoes", "accessories"]
    
    private var filteredItems: [ClothingItem] {
        let items = itemManager.getItems(for: selectedCategory)
        return sortItems(items, by: sortOption)
    }
    
    private func sortItems(_ items: [ClothingItem], by option: SortOption) -> [ClothingItem] {
        switch option {
        case .mostRecent:
            return items.sorted { item1, item2 in
                let days1 = item1.daysSinceLastWorn ?? Int.max
                let days2 = item2.daysSinceLastWorn ?? Int.max
                return days1 < days2
            }
        case .leastRecent:
            return items.sorted { item1, item2 in
                let days1 = item1.daysSinceLastWorn ?? Int.max
                let days2 = item2.daysSinceLastWorn ?? Int.max
                return days1 > days2
            }
        case .mostWorn:
            return items.sorted { $0.wearCount > $1.wearCount }
        case .leastWorn:
            return items.sorted { $0.wearCount < $1.wearCount }
        case .alphabetical:
            return items.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter and Sort Options - Aligned
                HStack(alignment: .center, spacing: 12) {
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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Sort Options - Icon Only
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                sortOption = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color(red: 0.373, green: 0.424, blue: 0.216)) // #5F6C37
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
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
                            .foregroundColor(.primary)
                        
                        Text("add items to your closet to start tracking your wardrobe")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.secondary)
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
                .background(isSelected ? Color.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ClothingItemCard: View {
    let item: ClothingItem
    let onTap: () -> Void
    @State private var loadedImage: UIImage?
    
    init(item: ClothingItem, onTap: @escaping () -> Void) {
        self.item = item
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Clothing item image - Fixed size (taller than wide)
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 160) // Increased height for larger image display
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if let image = loadedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                // Fallback to category icon
                                VStack(spacing: 4) {
                                    Image(systemName: item.category.icon)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text(item.color)
                                        .font(.custom("Poppins-Regular", size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    )
                    .clipped()
                
                // Text content - Fixed height container
                VStack(alignment: .leading, spacing: 4) {
                    // Item name
                    Text(item.name)
                        .font(.custom("Poppins-Medium", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 32) // Fixed height for 2 lines
                    
                    // Wear status with prominent color indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.wearStatus.color)
                            .frame(width: 12, height: 12) // Larger, more prominent
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lastWornText)
                                .font(.custom("Poppins-Medium", size: 12))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("Worn \(item.wearCount) times")
                                .font(.custom("Poppins-Regular", size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .frame(height: 32) // Fixed height for wear info
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 64) // Reduced height: 32 (name) + 4 (spacing) + 32 (wear info) = 68, but using 64 for cleaner look
            }
            .frame(height: 232) // Total fixed card height: 160 (image) + 8 (spacing) + 64 (text) = 232
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 12) // Extra space at bottom
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        loadedImage = UIImage(named: item.imageName)
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
                let weeks = days / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            } else {
                let months = days / 30
                return months == 1 ? "1 month ago" : "\(months) months ago"
            }
        } else {
            return "Never worn"
        }
    }
}

struct ImageModalView: View {
    let item: ClothingItem
    @Environment(\.presentationMode) var presentationMode
    @State private var loadedImage: UIImage?
    
    init(item: ClothingItem) {
        self.item = item
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with image
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .aspectRatio(4/5, contentMode: .fit)
                        .overlay(
                            Group {
                                if let image = loadedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image(systemName: "tshirt")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                        .clipped()
                        .cornerRadius(12)
                    
                    // Item name
                    Text(item.name)
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Metadata section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // Category on the left
                            HStack(spacing: 4) {
                                Text("Category:")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                Text(item.category.rawValue.capitalized)
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            // Date purchased on the right
                            if let dateBought = item.dateBought {
                                HStack(spacing: 4) {
                                    Text("Got:")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(.secondary)
                                    Text(formatShortDate(dateBought))
                                        .font(.custom("Poppins-Medium", size: 16))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                    
                    // Wear history section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Wear History")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.primary)
                        
                        // Last worn and fits count - side by side
                        HStack(spacing: 12) {
                            // Last worn container
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last worn")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(item.wearStatus.color)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(lastWornText)
                                        .font(.custom("Poppins-Medium", size: 14))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(item.wearStatus.color.opacity(0.1))
                            .cornerRadius(8)
                            
                            // Fits count container
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fits made")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                
                                Text("\(item.wearCount)")
                                    .font(.custom("Poppins-Medium", size: 14))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            
                            Spacer()
                        }
                        
                        // Recent wears gallery
                        if !item.wearHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent wears")
                                    .font(.custom("Poppins-Medium", size: 14))
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(item.wearHistory.prefix(10).enumerated()), id: \.offset) { index, date in
                                            VStack(spacing: 4) {
                                                // Placeholder outfit image
                                                Rectangle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(width: 60, height: 80)
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        Image(systemName: "tshirt")
                                                            .font(.system(size: 24))
                                                            .foregroundColor(.gray)
                                                    )
                                                
                                                Text(formatWearDate(date))
                                                    .font(.custom("Poppins-Regular", size: 10))
                                                    .foregroundColor(.primary)
                                                
                                                Text("\(daysAgo(from: date)) days ago")
                                                    .font(.custom("Poppins-Regular", size: 9))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                    
                    // Details section with editable fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Details")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            // Brand field
                            HStack {
                                Text("Brand:")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                TextField("Enter brand", text: .constant(item.brand ?? ""))
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Color field
                            HStack {
                                Text("Color:")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                TextField("Enter color", text: .constant(item.color))
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Size field
                            HStack {
                                Text("Size:")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                TextField("Enter size", text: .constant(item.size))
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Notes field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes:")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter notes", text: .constant(item.notes ?? ""), axis: .vertical)
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("item details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                loadImage()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var lastWornText: String {
        if let days = item.daysSinceLastWorn {
            if days == 0 {
                return "Today"
            } else if days == 1 {
                return "Yesterday"
            } else if days < 7 {
                return "\(days) days ago"
            } else if days < 30 {
                let weeks = days / 7
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            } else {
                let months = days / 30
                return months == 1 ? "1 month ago" : "\(months) months ago"
            }
        } else {
            return "Never worn"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatWearDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func daysAgo(from date: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        return components.day ?? 0
    }
    
    private func loadImage() {
        loadedImage = UIImage(named: item.imageName)
    }
}

// MARK: - Metadata Tag Components

struct MetadataTag: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Poppins-Regular", size: 10))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct CompactMetadataTag: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.custom("Poppins-Regular", size: 9))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.custom("Poppins-Medium", size: 11))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct SimpleTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.custom("Poppins-Medium", size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(16)
    }
}

struct LightTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.custom("Poppins-Regular", size: 11))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
}

enum SortOption: String, CaseIterable {
    case mostRecent = "Most Recent"
    case leastRecent = "Least Recent"
    case mostWorn = "Worn Most Often"
    case leastWorn = "Worn Least Often"
    case alphabetical = "A-Z"
}

struct ClosetView_Previews: PreviewProvider {
    static var previews: some View {
        ClosetView(itemManager: ClothingItemManager())
    }
}
