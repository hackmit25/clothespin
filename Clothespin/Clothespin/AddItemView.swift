import SwiftUI

struct AddItemView: View {
    @ObservedObject var itemManager: ClothingItemManager
    @Binding var selectedTab: Int
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSimulatorAlert = false
    @State private var brandName = ""
    @State private var selectedCategory = "Tops"
    @State private var showingSuccessAlert = false
    @State private var showingBrandSuggestions = false
    @State private var searchTask: Task<Void, Never>?
    
    let categories = ["Tops", "Bottoms", "Dresses", "Shoes", "Accessories"]
    
    // Popular fashion brands for auto-suggestions
    let brandSuggestions = [
        "Nike", "Adidas", "Zara", "H&M", "Uniqlo", "Gap", "Levi's", "Calvin Klein",
        "Tommy Hilfiger", "Ralph Lauren", "Champion", "Puma", "Converse", "Vans",
        "Urban Outfitters", "Forever 21", "ASOS", "Shein", "Depop", "Poshmark",
        "ThredUp", "Vintage", "Custom", "Other"
    ]
    
    private var filteredBrands: [String] {
        if brandName.isEmpty {
            return brandSuggestions
        } else {
            return brandSuggestions.filter { $0.lowercased().contains(brandName.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Section
                    VStack(spacing: 16) {
                        Text("Record Item Photo")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            VStack(spacing: 16) {
                                // Take Photo Button
                                Button(action: { 
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        showingCamera = true
                                    } else {
                                        showingSimulatorAlert = true
                                    }
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: UIImagePickerController.isSourceTypeAvailable(.camera) ? "camera.fill" : "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.primary)
                                        
                                        Text(UIImagePickerController.isSourceTypeAvailable(.camera) ? "Take Photo" : "Take Photo (Simulator)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                                            Text("Will open photo library in simulator")
                                                .font(.caption)
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: UIImagePickerController.isSourceTypeAvailable(.camera) ? 100 : 120)
                                    .background(Color.background)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    )
                                }
                                
                                // Select from Gallery Button
                                Button(action: { showingImagePicker = true }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                            .foregroundColor(.primary)
                                        Text("Select from Gallery")
                                            .foregroundColor(.primary)
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }
                        
                        if selectedImage != nil {
                            HStack(spacing: 16) {
                                Button("Retake Photo") {
                                    showingCamera = true
                                }
                                .foregroundColor(.primary)
                                
                                Button("Change Photo") {
                                    showingImagePicker = true
                                }
                                .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    selectedImage = nil
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Brand Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Brand")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            VStack(spacing: 0) {
                                TextField("Enter brand name", text: $brandName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onTapGesture {
                                        showingBrandSuggestions = true
                                    }
                                    .onChange(of: brandName) { _ in
                                        showingBrandSuggestions = true
                                        
                                        // Cancel previous search task
                                        searchTask?.cancel()
                                        
                                        // Start new search task with delay
                                        searchTask = Task {
                                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                                            if !Task.isCancelled {
                                                showingBrandSuggestions = false
                                            }
                                        }
                                    }
                                
                                // Brand Suggestions Dropdown
                                if showingBrandSuggestions && !filteredBrands.isEmpty {
                                    ScrollView {
                                        LazyVStack(spacing: 0) {
                                            ForEach(filteredBrands, id: \.self) { brand in
                                                Button(action: {
                                                    brandName = brand
                                                    showingBrandSuggestions = false
                                                }) {
                                                    HStack {
                                                        Text(brand)
                                                            .foregroundColor(.textPrimary)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                }
                                                .background(Color.background)
                                                
                                                if brand != filteredBrands.last {
                                                    Divider()
                                                        .padding(.leading, 12)
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 200)
                                    .background(Color.background)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(radius: 2)
                                }
                            }
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                    }
                    
                    // Add Button - matching design style
                    Button(action: addItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Record Item")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(selectedImage != nil && !brandName.isEmpty ? Color.primary : Color.gray)
                        .cornerRadius(25) // More rounded like the design
                    }
                    .disabled(selectedImage == nil || brandName.isEmpty)
                    
                    Spacer(minLength: 50)
                }
                .padding()
                .onTapGesture {
                    showingBrandSuggestions = false
                }
        }
        .navigationTitle("Record Item")
        .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .alert("Camera Not Available", isPresented: $showingSimulatorAlert) {
                Button("Use Photo Library") {
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Camera is not available in the simulator. Would you like to select a photo from your library instead?")
            }
            .alert("Item Added Successfully!", isPresented: $showingSuccessAlert) {
                Button("View in Closet") {
                    selectedTab = 1 // Navigate to Closet tab
                }
                Button("Add Another", role: .cancel) { }
            } message: {
                Text("Your \(selectedCategory.lowercased()) has been added to your closet.")
            }
        }
    }
    
    private func addItem() {
        guard let image = selectedImage else { return }
        
        // Add item to the manager
        itemManager.addItem(name: brandName, category: selectedCategory, image: image)
        
        // Show success alert
        showingSuccessAlert = true
        
        // Reset form
        selectedImage = nil
        brandName = ""
        selectedCategory = "Tops"
        showingBrandSuggestions = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        // Check if the source type is available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            // Fallback to photo library if camera is not available (e.g., in simulator)
            picker.sourceType = .photoLibrary
        }
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(itemManager: ClothingItemManager(), selectedTab: .constant(2))
    }
}
