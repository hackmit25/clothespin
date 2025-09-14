import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var tabBarHeight: CGFloat = 0
    @EnvironmentObject var itemManager: ClothingItemManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                ClosetView(itemManager: itemManager)
                    .tag(1)
                
                AddItemView(itemManager: itemManager, selectedTab: $selectedTab)
                    .tag(2)
                
                StatsView()
                    .tag(3)
                
                DonateView()
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    TabBarButton(
                        index: index,
                        selectedTab: $selectedTab,
                        tabBarHeight: $tabBarHeight
                    )
                }
            }
            .background(Color.white)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            tabBarHeight = geometry.size.height
                        }
                }
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TabBarButton: View {
    let index: Int
    @Binding var selectedTab: Int
    @Binding var tabBarHeight: CGFloat
    @State private var isPressed = false
    
    private var isSelected: Bool {
        selectedTab == index
    }
    
    private var tabInfo: (icon: String, title: String) {
        switch index {
        case 0: return ("house.fill", "home")
        case 1: return ("cabinet.fill", "closet")
        case 2: return ("plus.circle.fill", "add item")
        case 3: return ("lightbulb.fill", "insights")
        case 4: return ("arrow.3.trianglepath", "donate")
        default: return ("circle", "tab")
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    // Icon with enhanced animation
                    Image(systemName: tabInfo.icon)
                        .font(.system(size: isSelected ? 22 : 18, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color(red: 0.373, green: 0.424, blue: 0.216) : .gray)
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2), value: isSelected)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                }
                .frame(height: 26)
                
                Text(tabInfo.title)
                    .font(.custom("Poppins-Medium", size: isSelected ? 11 : 10))
                    .foregroundColor(isSelected ? Color(red: 0.373, green: 0.424, blue: 0.216) : .gray)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(0))
            .environmentObject(ClothingItemManager())
    }
}
