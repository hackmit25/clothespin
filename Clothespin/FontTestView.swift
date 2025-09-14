import SwiftUI

struct FontTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Font Test")
                .font(.title)
            
            Text("Poppins Regular")
                .font(.custom("Poppins-Regular", size: 20))
            
            Text("Poppins Medium")
                .font(.custom("Poppins-Medium", size: 20))
            
            Text("Poppins SemiBold")
                .font(.custom("Poppins-SemiBold", size: 20))
            
            Text("Poppins Bold")
                .font(.custom("Poppins-Bold", size: 20))
            
            // Alternative naming
            Text("Poppins (alt)")
                .font(.custom("Poppins", size: 20))
            
            Text("System Font")
                .font(.system(size: 20, weight: .medium))
        }
        .onAppear {
            print("Available fonts:")
            for family in UIFont.familyNames.sorted() {
                if family.contains("Poppins") {
                    print("Family: \(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("  - \(name)")
                    }
                }
            }
        }
    }
}

struct FontTestView_Previews: PreviewProvider {
    static var previews: some View {
        FontTestView()
    }
}
