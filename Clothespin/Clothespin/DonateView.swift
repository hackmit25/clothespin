import SwiftUI
import MapKit
import CoreLocation

struct DonationRecord: Identifiable {
    let id = UUID()
    let date: Date
    let location: String
    let itemCount: Int
    let qrCodeData: String
}

struct DonateView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var pointsManager = PointsManager()
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showingQRModal = false
    @State private var showingRewardsModal = false
    @State private var donationCount = 1
    @State private var selectedLocation = "Local Donation Center"
    @State private var donationHistory: [DonationRecord] = []
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "locations"
        case 1: return "my donations"
        case 2: return "impact"
        default: return ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector - Custom Button Style
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabTitle(for: index))
                                .font(.custom("Poppins-Medium", size: 16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTab == index ? Color(red: 0.373, green: 0.424, blue: 0.216) : Color(.systemGray6))
                                .foregroundColor(selectedTab == index ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Nearby Locations Tab
                    NearbyLocationsView(locationManager: locationManager, isLoading: $isLoading)
                        .tag(0)
                    
                    // My Donations Tab
                    MyDonationsTabView(donationHistory: donationHistory)
                        .tag(1)
                    
                    // Impact Tab
                    ImpactView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("donate")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.titleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .semibold),
                    .foregroundColor: UIColor(Color.darkGreen)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont(name: "Poppins-SemiBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .semibold),
                    .foregroundColor: UIColor(Color.darkGreen)
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Points Display
                        Button(action: {
                            showingRewardsModal = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow)
                                
                                Text("1,250")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        }
                        
                        // QR Code Button
                        Button(action: {
                            showingQRModal = true
                        }) {
                            Image(systemName: "qrcode")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingQRModal) {
                DonationQRModal(
                    donationCount: $donationCount,
                    selectedLocation: $selectedLocation,
                    isPresented: $showingQRModal,
                    donationHistory: $donationHistory,
                    pointsManager: pointsManager
                )
            }
            .sheet(isPresented: $showingRewardsModal) {
                RewardsModal(pointsManager: pointsManager, isPresented: $showingRewardsModal)
            }
        }
    }
}

struct NearbyLocationsView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var isLoading: Bool
    @State private var locations: [DonationLocation] = []
    @State private var searchText = ""
    @State private var showingLocationAlert = false
    @State private var selectedType: LocationType? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                TextField("search city or address", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchDonationCenters()
                    }
                
                Button("search") {
                    searchDonationCenters()
                }
                .disabled(searchText.isEmpty)
            }
            .padding(.horizontal)
            
            // Location Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All Types Button
                    Button(action: {
                        selectedType = nil
                        searchDonationCenters()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "circle.grid.2x2.fill")
                            Text("all")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedType == nil ? Color.primary : Color.cardBackground)
                        .foregroundColor(selectedType == nil ? .white : .textPrimary)
                        .cornerRadius(16)
                    }
                    
                    ForEach(LocationType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                            searchDonationCenters()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: type.icon)
                                Text(type.rawValue.lowercased())
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedType == type ? type.color : Color.cardBackground)
                            .foregroundColor(selectedType == type ? .white : .textPrimary)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Location Status
            if locationManager.authorizationStatus == .denied {
                VStack {
                    Text("location access denied")
                        .foregroundColor(.red)
                    Button("enable in settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else if locationManager.authorizationStatus == .notDetermined {
                Button("Enable Location Access") {
                    locationManager.requestLocation()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            
            Spacer()
                .frame(height: 16)
            
            // Map View
            Map(coordinateRegion: $locationManager.region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: location.type.icon)
                            .foregroundColor(location.type.color)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            )
                        Text(location.name)
                            .font(.custom("Poppins-Regular", size: 10))
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                            .lineLimit(2)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Loading Indicator
            if isLoading {
                HStack {
                    ProgressView()
                    Text("searching for donation centers...")
                }
                .padding()
            }
            
            // Locations List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if locations.isEmpty && !isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "map")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("no donation centers found")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.secondary)
                            
                            Text("try searching for a different city or enable location access")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 50)
                    } else {
                        ForEach(locations, id: \.name) { location in
                            DonationLocationCard(location: location)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                searchDonationCenters()
            }
        }
        .onChange(of: locationManager.location) { _ in
            if locationManager.location != nil {
                searchDonationCenters()
            }
        }
    }
    
    private func searchDonationCenters() {
        isLoading = true
        
        if searchText.isEmpty {
            // Search near user's current location
            if let userLocation = locationManager.location {
                if selectedType == nil {
                    // Use comprehensive search for "All" types
                    DonationCenterService.searchAllLocationTypes(near: userLocation) { foundLocations in
                        self.locations = foundLocations
                        self.isLoading = false
                    }
                } else {
                    // Use specific search for selected type
                    DonationCenterService.searchLocations(near: userLocation, type: selectedType) { foundLocations in
                        self.locations = foundLocations
                        self.isLoading = false
                    }
                }
            } else {
                // Use default location if no user location
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
                if selectedType == nil {
                    DonationCenterService.searchAllLocationTypes(near: defaultLocation) { foundLocations in
                        self.locations = foundLocations
                        self.isLoading = false
                    }
                } else {
                    DonationCenterService.searchLocations(near: defaultLocation, type: selectedType) { foundLocations in
                        self.locations = foundLocations
                        self.isLoading = false
                    }
                }
            }
        } else {
            // Search in specific city
            DonationCenterService.searchLocations(in: searchText, type: selectedType) { foundLocations in
                self.locations = foundLocations
                self.isLoading = false
            }
        }
    }
}

struct MyDonationsView: View {
    let donationHistory: [DonationRecord]
    
    var totalItemsDonated: Int {
        donationHistory.reduce(0) { $0 + $1.itemCount }
    }
    
    var uniqueLocations: Int {
        Set(donationHistory.map { $0.location }).count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Donation Summary
                VStack(spacing: 16) {
                    Text("your donation impact")
                        .font(.custom("Poppins-Bold", size: 22))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DonateStatCard(title: "items donated", value: "\(totalItemsDonated)", icon: "tshirt.fill")
                        DonateStatCard(title: "locations visited", value: "\(uniqueLocations)", icon: "location.fill")
                        DonateStatCard(title: "lives impacted", value: "\(totalItemsDonated)", icon: "person.2.fill")
                        DonateStatCard(title: "carbon saved", value: "\(totalItemsDonated * 4) lbs", icon: "leaf.fill")
                    }
                    .padding(.horizontal)
                }
                
                // Recent Donations
                VStack(alignment: .leading, spacing: 16) {
                    Text("recent donations")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.darkGreen)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        if donationHistory.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.primary)
                                
                                Text("no donations yet")
                                    .font(.custom("Poppins-SemiBold", size: 20))
                                    .foregroundColor(.textPrimary)
                                
                                Text("start your donation journey by using the qr code feature!")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(donationHistory.sorted(by: { $0.date > $1.date })) { donation in
                                    RecentDonationCard(donation: donation)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.top)
        }
    }
}

struct ImpactView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Environmental Impact
                VStack(alignment: .leading, spacing: 16) {
                    Text("environmental impact")
                        .font(.custom("Poppins-Bold", size: 22))
                    
                    ImpactCard(
                        icon: "leaf.fill",
                        title: "carbon footprint reduction",
                        description: "Each clothing item donated instead of thrown away saves approximately 27kg of CO2 emissions.",
                        value: "0 kg CO2 saved"
                    )
                    
                    ImpactCard(
                        icon: "drop.fill",
                        title: "water conservation",
                        description: "Donating clothes reduces the demand for new clothing production, saving thousands of gallons of water per item.",
                        value: "0 gallons saved"
                    )
                    
                    ImpactCard(
                        icon: "trash.fill",
                        title: "waste reduction",
                        description: "Keep clothing out of landfills where synthetic materials can take hundreds of years to decompose.",
                        value: "0 items diverted"
                    )
                }
                .padding(.horizontal)
                
                // Social Impact
                VStack(alignment: .leading, spacing: 16) {
                    Text("social impact")
                        .font(.custom("Poppins-Bold", size: 22))
                    
                    ImpactCard(
                        icon: "person.2.fill",
                        title: "community support",
                        description: "Your donations help provide affordable clothing options for families in need.",
                        value: "0 families helped"
                    )
                    
                    ImpactCard(
                        icon: "briefcase.fill",
                        title: "job creation",
                        description: "Donation centers and thrift stores create employment opportunities in your community.",
                        value: "0 jobs supported"
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
            .padding(.top)
        }
    }
}

struct DonationLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: String
    let coordinate: CLLocationCoordinate2D
    let hours: String
    let accepts: [String]
    let type: LocationType
}

struct DonationLocationCard: View {
    let location: DonationLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(location.name)
                            .font(.custom("Poppins-SemiBold", size: 18))
                        
                        // Location type badge
                        HStack(spacing: 4) {
                            Image(systemName: location.type.icon)
                                .font(.caption2)
                            Text(location.type.rawValue.lowercased())
                                .font(.custom("Poppins-Regular", size: 10))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(location.type.color.opacity(0.2))
                        .foregroundColor(location.type.color)
                        .cornerRadius(8)
                    }
                    
                    Text(location.address)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(location.distance)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("📍")
                        .font(.title2)
                }
            }
            
            Text(location.hours)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Accepts:")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(location.accepts, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primary.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1) // Small padding to prevent clipping
                }
            }
            
            Button("Get Directions") {
                // TODO: Open maps app
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.primary)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct DonateStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
            
            Text(value)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}


struct EmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct ImpactCard: View {
    let icon: String
    let title: String
    let description: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 18))
                
                Spacer()
                
                Text(value)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.green)
            }
            
            Text(description)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentDonationCard: View {
    let donation: DonationRecord
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(donation.itemCount) item(s) donated")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(donation.location)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(donation.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("✓")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("Complete")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct DonationQRModal: View {
    @Binding var donationCount: Int
    @Binding var selectedLocation: String
    @Binding var isPresented: Bool
    @Binding var donationHistory: [DonationRecord]
    @ObservedObject var pointsManager: PointsManager
    @State private var showingSuccessAlert = false
    
    let locations = [
        "Goodwill",
        "Salvation Army",
        "Local Thrift Store",
        "Community Donation Center",
        "Red Cross",
        "Habitat for Humanity"
    ]
    
    var qrCodeData: String {
        // In a real app, this would be a unique donation ID
        return "clothespin:donation:\(donationCount):\(selectedLocation):\(Date().timeIntervalSince1970)"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 40))
                        .foregroundColor(.primary)
                    
                    Text("Donation QR Code")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Show this QR code to the donation center staff")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // QR Code Display
                VStack(spacing: 16) {
                    // QR Code placeholder (in a real app, you'd generate an actual QR code)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .frame(width: 200, height: 200)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 80))
                                .foregroundColor(.black)
                            
                            Text("QR Code")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Donation ID: \(qrCodeData.suffix(8))")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal)
                }
                
                // Donation Details
                VStack(spacing: 16) {
                    // Item Count Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Items")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        HStack {
                            Button(action: {
                                if donationCount > 1 {
                                    donationCount -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            .disabled(donationCount <= 1)
                            
                            Spacer()
                            
                            Text("\(donationCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                                .frame(minWidth: 40)
                            
                            Spacer()
                            
                            Button(action: {
                                donationCount += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    // Location Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Donation Location")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Menu {
                            ForEach(locations, id: \.self) { location in
                                Button(location) {
                                    selectedLocation = location
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedLocation)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.textSecondary)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Save the donation record
                        let newDonation = DonationRecord(
                            date: Date(),
                            location: selectedLocation,
                            itemCount: donationCount,
                            qrCodeData: qrCodeData
                        )
                        donationHistory.append(newDonation)
                        
                        // Award points for donation
                        pointsManager.addDonationPoints(itemCount: donationCount, location: selectedLocation)
                        
                        showingSuccessAlert = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Donation")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.primary) // Dark olive green
                        .cornerRadius(25) // More rounded like the design
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("make donation")
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .alert("Donation Recorded!", isPresented: $showingSuccessAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text("Thank you for your donation of \(donationCount) item(s) to \(selectedLocation)!")
        }
    }
}

struct MyDonationsTabView: View {
    let donationHistory: [DonationRecord]
    @StateObject private var itemManager = ClothingItemManager()
    
    
    // Get the 2 least worn items for recent donations
    private var recentDonations: [ClothingItem] {
        let allItems = itemManager.items
        let sortedByWearCount = allItems.sorted { $0.wearCount < $1.wearCount }
        return Array(sortedByWearCount.prefix(2))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Overview
                VStack(spacing: 16) {
                    Text("my impact")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.darkGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Total Items Donated
                        VStack(spacing: 6) {
                            Text("2")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(.white)
                            Text("items donated")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.sageGreen)
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                        
                        // Total Donations
                        VStack(spacing: 6) {
                            Text("1")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(.white)
                            Text("donation made")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.darkGreen)
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                        
                        // Carbon Saved (realistic estimate: ~54kg CO2 for 2 items)
                        VStack(spacing: 6) {
                            Text("54kg")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(.white)
                            Text("CO₂ saved")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.warmBrown)
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                        
                        // Water Saved (realistic estimate: ~4,000L for 2 items)
                        VStack(spacing: 6) {
                            Text("4kL")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(.white)
                            Text("water saved")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.rust)
                        .cornerRadius(12)
                        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
                
                // Recent Donations
                VStack(alignment: .leading, spacing: 16) {
                    Text("recent donations")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.darkGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(recentDonations) { item in
                            DonationItemCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Donation History
                if !donationHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("donation history")
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(donationHistory.reversed()) { donation in
                                DonationHistoryCard(donation: donation)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
        .background(Color.white)
    }
}

struct DonationItemCard: View {
    let item: ClothingItem
    @State private var loadedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            Rectangle()
                .fill(Color(.systemGray6))
                .aspectRatio(4/5, contentMode: .fit)
                .overlay(
                    Group {
                        if let image = loadedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: "tshirt")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                )
                .cornerRadius(8, corners: [.topLeft, .topRight])
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("donated")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
        .onAppear {
            loadedImage = UIImage(named: item.imageName)
        }
    }
}

struct DonationHistoryCard: View {
    let donation: DonationRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "gift.fill")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("\(donation.itemCount) item\(donation.itemCount == 1 ? "" : "s") donated")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.primary)
                
                Text(donation.location)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                
                Text(formatDate(donation.date))
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points earned
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(donation.itemCount * 50)")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.green)
                Text("points")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
