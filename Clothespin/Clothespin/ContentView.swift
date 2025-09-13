import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ClosetView()
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Closet")
                }
            
            AddItemView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            DonateView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Donate")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
