import SwiftUI

struct ContentView: View {
    @StateObject private var itemManager = ClothingItemManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("home")
                }
                .tag(0)
            
            ClosetView(itemManager: itemManager)
                .tabItem {
                    Image(systemName: "door.left.hand.open")
                    Text("closet")
                }
                .tag(1)
            
            AddItemView(itemManager: itemManager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("record item")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("insights")
                }
                .tag(3)
            
            DonateView()
                .tabItem {
                    Image(systemName: "arrow.3.trianglepath")
                    Text("donate")
                }
                .tag(4)
        }
        .accentColor(.primary)
        .background(Color.white)
        .onAppear {
            // Remove tab bar border and set white background
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            appearance.shadowColor = .clear // Remove border/shadow
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
