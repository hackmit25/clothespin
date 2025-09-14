import SwiftUI

struct ContentView: View {
    @StateObject private var itemManager = ClothingItemManager()
    @State private var selectedTab = 0
    
    var body: some View {
        CustomTabBar(selectedTab: $selectedTab)
            .environmentObject(itemManager)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
