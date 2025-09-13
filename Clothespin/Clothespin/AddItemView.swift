import SwiftUI

struct AddItemView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var itemName = ""
    @State private var selectedCategory = "Tops"
    @State private var purchaseDate = Date()
    
    let categories = ["Tops", "Bottoms", "Dresses", "Shoes", "Accessories"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Section
                    VStack(spacing: 16) {
                        Text("Add Photo")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            Button(action: { showingImagePicker = true }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    
                                    Text("Take Photo")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Text("or tap to select from gallery")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                )
                            }
                        }
                        
                        if selectedImage != nil {
                            HStack(spacing: 16) {
                                Button("Retake Photo") {
                                    showingCamera = true
                                }
                                .foregroundColor(.blue)
                                
                                Button("Change Photo") {
                                    showingImagePicker = true
                                }
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    selectedImage = nil
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Item Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item Name")
                                .font(.headline)
                            
                            TextField("Enter item name", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Purchase Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Date")
                                .font(.headline)
                            
                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                    
                    // Add Button
                    Button(action: addItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Closet")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedImage != nil && !itemName.isEmpty ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(selectedImage == nil || itemName.isEmpty)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
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
        purchaseDate = Date()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
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
