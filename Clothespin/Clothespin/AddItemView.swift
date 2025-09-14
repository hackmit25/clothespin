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
    @State private var showingBrandSuggestions = false
    @State private var searchTask: Task<Void, Never>?
    
    let categories = ["tops", "bottoms", "dresses", "shoes", "accessories"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Section
                    VStack(spacing: 16) {
                        Text("record item photo")
                            .font(.custom("Poppins-SemiBold", size: 18))
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
                                        
                                        Text(UIImagePickerController.isSourceTypeAvailable(.camera) ? "take photo" : "take photo (simulator)")
                                            .font(.custom("Poppins-SemiBold", size: 18))
                                            .foregroundColor(.primary)
                                        
                                        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                                            Text("will open photo library in simulator")
                                                .font(.custom("Poppins-Regular", size: 12))
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
                                        Text("select from gallery")
                                            .foregroundColor(.primary)
                                    }
                                    .font(.custom("Poppins-Regular", size: 16))
                                }
                            }
                        }
                        
                        if selectedImage != nil {
                            HStack(spacing: 16) {
                                Button("retake photo") {
                                    showingCamera = true
                                }
                                .foregroundColor(.primary)
                                
                                Button("change photo") {
                                    showingImagePicker = true
                                }
                                .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button("remove") {
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
                            Text("item name")
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
                            
                            Picker("category", selection: $selectedCategory) {
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
                            Text("record item")
                        }
                        .font(.custom("Poppins-SemiBold", size: 18))
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
        .navigationTitle("record item")
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
        itemManager.addItem(name: brandName, category: selectedCategory, image: image)
        
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
