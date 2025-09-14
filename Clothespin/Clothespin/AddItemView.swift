import SwiftUI

struct AddItemView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingSimulatorAlert = false
    @State private var itemName = ""
    @State private var selectedCategory = "Tops"
    
    let categories = ["Tops", "Bottoms", "Dresses", "Shoes", "Accessories"]
    
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
                        // Item Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item Name")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            TextField("Enter item name", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        .background(selectedImage != nil && !itemName.isEmpty ? Color.primary : Color.gray)
                        .cornerRadius(25) // More rounded like the design
                    }
                    .disabled(selectedImage == nil || itemName.isEmpty)
                    
                    Spacer(minLength: 50)
                }
                .padding()
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
        }
    }
    
    private func addItem() {
        // TODO: Implement adding item to closet
        print("Adding item: \(itemName) of category: \(selectedCategory)")
        
        // Reset form
        selectedImage = nil
        itemName = ""
        selectedCategory = "Tops"
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
        AddItemView()
    }
}
