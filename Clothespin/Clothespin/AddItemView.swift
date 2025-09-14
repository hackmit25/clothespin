import SwiftUI

struct AddItemView: View {
    @ObservedObject var itemManager: ClothingItemManager
    @Binding var selectedTab: Int
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSimulatorAlert = false
    @State private var itemName = ""
    @State private var selectedCategory = "tops"
    @State private var showingSuccessAlert = false
    
    let categories = ["tops", "bottoms", "dresses", "shoes", "accessories"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Section
                    VStack(spacing: 16) {
                        Text("photo")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let selectedImage = selectedImage {
                            // Display selected image with overlay controls
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                    .clipped()
                                
                                // Remove button overlay
                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                            }
                        } else {
                            // Photo selection options
                            VStack(spacing: 20) {
                                // Main photo area with dashed border
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(red: 0.373, green: 0.424, blue: 0.216))
                                    
                                    VStack(spacing: 4) {
                                        Text("add a photo")
                                            .font(.custom("Poppins-SemiBold", size: 20))
                                            .foregroundColor(.darkGreen)
                                        
                                        Text("take a new photo or choose from gallery")
                                            .font(.custom("Poppins-Regular", size: 14))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 140)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.373, green: 0.424, blue: 0.216), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                )
                                
                                // Action buttons
                                HStack(spacing: 12) {
                                    // Take Photo Button
                                    Button(action: { 
                                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                            showingCamera = true
                                        } else {
                                            showingSimulatorAlert = true
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title3)
                                            Text("camera")
                                                .font(.custom("Poppins-Medium", size: 16))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(red: 0.373, green: 0.424, blue: 0.216))
                                        .cornerRadius(25)
                                    }
                                    
                                    // Gallery Button
                                    Button(action: { showingImagePicker = true }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.title3)
                                            Text("gallery")
                                                .font(.custom("Poppins-Medium", size: 16))
                                        }
                                        .foregroundColor(Color(red: 0.373, green: 0.424, blue: 0.216))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(red: 0.373, green: 0.424, blue: 0.216), lineWidth: 1)
                                        )
                                    }
                                }
                                
                                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    Text("camera will open photo library in simulator")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        
                    }
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Item Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("name")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.textPrimary)
                            
                            TextField("enter item name", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("category")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.textPrimary)
                            
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
                                .padding(.horizontal, 4)
                            }
                        }
                        
                    }
                    
                    // Add Button - matching design style
                    Button(action: addItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("add item")
                        }
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedImage != nil && !itemName.isEmpty ? Color(red: 0.373, green: 0.424, blue: 0.216) : Color.gray)
                        .cornerRadius(50)
                    }
                    .disabled(selectedImage == nil || itemName.isEmpty)
                    
                    Spacer(minLength: 50)
                }
                .padding()
        }
        .navigationTitle("add item")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            appearance.titleTextAttributes = [
                .font: UIFont(name: "Poppins-SemiBold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .semibold)
            ]
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "Poppins-SemiBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold)
            ]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .alert("camera not available", isPresented: $showingSimulatorAlert) {
                Button("use photo library") {
                    showingImagePicker = true
                }
                Button("cancel", role: .cancel) { }
            } message: {
                Text("camera is not available in the simulator. would you like to select a photo from your library instead?")
            }
            .alert("item added successfully!", isPresented: $showingSuccessAlert) {
                Button("view in closet") {
                    selectedTab = 1 // Navigate to Closet tab
                }
                Button("add another", role: .cancel) { }
            } message: {
                Text("your \(selectedCategory.lowercased()) has been added to your closet.")
            }
            .alert("item added successfully!", isPresented: $showingSuccessAlert) {
                Button("view in closet") {
                    selectedTab = 1 // Navigate to Closet tab
                }
                Button("add another", role: .cancel) { }
            } message: {
                Text("your \(selectedCategory.lowercased()) has been added to your closet.")
            }
        }
    }
    
    private func addItem() {
        guard let image = selectedImage else { return }
        
        // Add item to the manager
        itemManager.addItem(name: itemName, category: selectedCategory, image: image)
        
        // Show success alert
        showingSuccessAlert = true
        
        // Reset form
        selectedImage = nil
        itemName = ""
        selectedCategory = "tops"
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
