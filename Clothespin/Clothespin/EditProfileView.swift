import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fullName: String
    @Binding var username: String
    @Binding var location: String
    @Binding var profileImage: UIImage?
    
    @State private var tempFullName = ""
    @State private var tempUsername = ""
    @State private var tempLocation = ""
    @State private var tempProfileImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Edit Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        // Profile Picture Section
                        VStack(spacing: 16) {
                            Text("Profile Picture")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                showImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 120, height: 120)
                                    
                                    if let tempProfileImage = tempProfileImage {
                                        Image(uiImage: tempProfileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title)
                                                .foregroundColor(.blue)
                                            Text("Change Photo")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Full Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your full name", text: $tempFullName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Choose a username", text: $tempUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                            }
                            
                            // Location Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("City, Country", text: $tempLocation)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Save Changes")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.titleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    tempProfileImage = image
                }
            }
        }
        .onAppear {
            tempFullName = fullName
            tempUsername = username
            tempLocation = location
            tempProfileImage = profileImage
        }
    }
    
    private var isFormValid: Bool {
        !tempFullName.isEmpty && !tempUsername.isEmpty && !tempLocation.isEmpty
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate save delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            fullName = tempFullName
            username = tempUsername
            location = tempLocation
            profileImage = tempProfileImage
            
            isLoading = false
            dismiss()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            fullName: .constant("John Doe"),
            username: .constant("johndoe"),
            location: .constant("San Francisco, CA"),
            profileImage: .constant(nil)
        )
    }
}
