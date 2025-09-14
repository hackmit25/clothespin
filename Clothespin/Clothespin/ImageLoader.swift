import SwiftUI
import UIKit

public class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let imageName: String
    
    public init(imageName: String) {
        self.imageName = imageName
        loadImage()
    }
    
    private func loadImage() {
        // Try to load from ClothingImages.imageset first
        if let bundleImage = UIImage(named: imageName) {
            self.image = bundleImage
        } else {
            // Ultimate fallback - create a placeholder
            self.image = createPlaceholderImage()
        }
    }
    
    private func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Light gray background
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add a simple icon
            let iconSize: CGFloat = 60
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            UIColor.darkGray.setFill()
            context.fill(iconRect)
        }
    }
}

public struct ClothingImageView: View {
    let imageName: String
    @StateObject private var imageLoader: ImageLoader
    
    public init(imageName: String) {
        self.imageName = imageName
        self._imageLoader = StateObject(wrappedValue: ImageLoader(imageName: imageName))
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Fallback placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.gray)
                )
        }
    }
}
