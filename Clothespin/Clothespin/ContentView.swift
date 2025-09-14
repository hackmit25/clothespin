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
                    Image(systemName: "cabinet.fill")
                    Text("closet")
                }
                .tag(1)
            
            AddItemView(itemManager: itemManager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                    Text("add item")
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
        .accentColor(Color(red: 0.373, green: 0.424, blue: 0.216)) // #5F6C37
        .background(Color.white)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            appearance.shadowColor = .clear
            
            // Style the middle button (add item) differently
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor.gray
            itemAppearance.selected.iconColor = UIColor(red: 0.373, green: 0.424, blue: 0.216, alpha: 1.0)
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.373, green: 0.424, blue: 0.216, alpha: 1.0)]
            
            appearance.stackedLayoutAppearance = itemAppearance
            
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
