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
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var showingQRModal = false
    @State private var donationCount = 1
    @State private var selectedLocation = "Local Donation Center"
    @State private var donationHistory: [DonationRecord] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Nearby").tag(0)
                    Text("My Donations").tag(1)
                    Text("Impact").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.background)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Nearby Locations Tab
                    NearbyLocationsView(locationManager: locationManager, isLoading: $isLoading)
                        .tag(0)
                    
                    // My Donations Tab
                    MyDonationsView(donationHistory: donationHistory)
                        .tag(1)
                    
                    // Impact Tab
                    ImpactView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingQRModal = true
                    }) {
                        Image(systemName: "qrcode")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingQRModal) {
                DonationQRModal(
                    donationCount: $donationCount,
                    selectedLocation: $selectedLocation,
                    isPresented: $showingQRModal,
                    donationHistory: $donationHistory
                )
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
                TextField("Search city or address", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchDonationCenters()
                    }
                
                Button("Search") {
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
                            Text("All")
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
                                Text(type.rawValue)
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
                    Text("Location access denied")
                        .foregroundColor(.red)
                    Button("Enable in Settings") {
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
                            .font(.caption2)
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
                    Text("Searching for donation centers...")
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
                            
                            Text("No donation centers found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Try searching for a different city or enable location access")
                                .font(.subheadline)
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
                    Text("Your Donation Impact")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        DonateStatCard(title: "Items Donated", value: "\(totalItemsDonated)", icon: "tshirt.fill")
                        DonateStatCard(title: "Locations Visited", value: "\(uniqueLocations)", icon: "location.fill")
                        DonateStatCard(title: "Lives Impacted", value: "\(totalItemsDonated)", icon: "person.2.fill")
                        DonateStatCard(title: "Carbon Saved", value: "\(totalItemsDonated * 4) lbs", icon: "leaf.fill")
                    }
                    .padding(.horizontal)
                }
                
                // Recent Donations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Donations")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        if donationHistory.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.primary)
                                
                                Text("No donations yet")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                Text("Start your donation journey by using the QR code feature!")
                                    .font(.subheadline)
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
                    Text("Environmental Impact")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ImpactCard(
                        icon: "leaf.fill",
                        title: "Carbon Footprint Reduction",
                        description: "Each clothing item donated instead of thrown away saves approximately 27kg of CO2 emissions.",
                        value: "0 kg CO2 saved"
                    )
                    
                    ImpactCard(
                        icon: "drop.fill",
                        title: "Water Conservation",
                        description: "Donating clothes reduces the demand for new clothing production, saving thousands of gallons of water per item.",
                        value: "0 gallons saved"
                    )
                    
                    ImpactCard(
                        icon: "trash.fill",
                        title: "Waste Reduction",
                        description: "Keep clothing out of landfills where synthetic materials can take hundreds of years to decompose.",
                        value: "0 items diverted"
                    )
                }
                .padding(.horizontal)
                
                // Social Impact
                VStack(alignment: .leading, spacing: 16) {
                    Text("Social Impact")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ImpactCard(
                        icon: "person.2.fill",
                        title: "Community Support",
                        description: "Your donations help provide affordable clothing options for families in need.",
                        value: "0 families helped"
                    )
                    
                    ImpactCard(
                        icon: "briefcase.fill",
                        title: "Job Creation",
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
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Location type badge
                        HStack(spacing: 4) {
                            Image(systemName: location.type.icon)
                                .font(.caption2)
                            Text(location.type.rawValue)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(location.type.color.opacity(0.2))
                        .foregroundColor(location.type.color)
                        .cornerRadius(8)
                    }
                    
                    Text(location.address)
                        .font(.subheadline)
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
            
            HStack {
                Text("Accepts:")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                ForEach(location.accepts, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
    }
}

struct DonationItemCard: View {
    let icon: String
    let title: String
    let description: String
    let date: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button("Donate") {
                // TODO: Handle donation action
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primary)
            .cornerRadius(8)
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
                    .font(.headline)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            Text(description)
                .font(.subheadline)
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
                        showingSuccessAlert = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Donation")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .cornerRadius(12)
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
            .navigationTitle("Make Donation")
            .navigationBarTitleDisplayMode(.inline)
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

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
