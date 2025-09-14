import SwiftUI

struct ContentView: View {
    @StateObject private var itemManager = ClothingItemManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ClosetView(itemManager: itemManager)
                .tabItem {
                    Image(systemName: "door.left.hand.open")
                    Text("Closet")
                }
                .tag(1)
            
            AddItemView(itemManager: itemManager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Record Item")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Insights")
                }
                .tag(3)
            
            DonateView()
                .tabItem {
                    Image(systemName: "arrow.3.trianglepath")
                    Text("Donate")
                }
                .tag(4)
        }
        .accentColor(.primary)
        .background(Color.background.ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
