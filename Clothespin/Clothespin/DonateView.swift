import SwiftUI
import MapKit

struct DonateView: View {
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
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
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Nearby Locations Tab
                    NearbyLocationsView(region: $region)
                        .tag(0)
                    
                    // My Donations Tab
                    MyDonationsView()
                        .tag(1)
                    
                    // Impact Tab
                    ImpactView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct NearbyLocationsView: View {
    @Binding var region: MKCoordinateRegion
    @State private var locations = [
        DonationLocation(
            name: "Goodwill San Francisco",
            address: "123 Market St, San Francisco, CA",
            distance: "0.5 miles",
            coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
            hours: "Mon-Sat: 9AM-8PM, Sun: 10AM-7PM",
            accepts: ["Clothing", "Shoes", "Accessories"]
        ),
        DonationLocation(
            name: "Salvation Army",
            address: "456 Mission St, San Francisco, CA",
            distance: "0.8 miles",
            coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
            hours: "Mon-Fri: 8AM-6PM, Sat: 9AM-5PM",
            accepts: ["Clothing", "Household Items"]
        ),
        DonationLocation(
            name: "Buffalo Exchange",
            address: "789 Valencia St, San Francisco, CA",
            distance: "1.2 miles",
            coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4394),
            hours: "Mon-Sun: 10AM-8PM",
            accepts: ["Vintage Clothing", "Designer Items"]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Map View
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
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
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Locations List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(locations, id: \.name) { location in
                        DonationLocationCard(location: location)
                    }
                }
                .padding()
            }
        }
    }
}

struct MyDonationsView: View {
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
                        DonateStatCard(title: "Items Donated", value: "0", icon: "tshirt.fill")
                        DonateStatCard(title: "Locations Visited", value: "0", icon: "location.fill")
                        DonateStatCard(title: "Lives Impacted", value: "0", icon: "person.2.fill")
                        DonateStatCard(title: "Carbon Saved", value: "0 lbs", icon: "leaf.fill")
                    }
                    .padding(.horizontal)
                }
                
                // Recent Donations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Donations")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        EmptyStateCard(
                            icon: "heart.fill",
                            title: "No donations yet",
                            description: "Start by adding items to your closet and marking them for donation when you're ready to let them go."
                        )
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
}

struct DonationLocationCard: View {
    let location: DonationLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                    
                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(location.distance)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("📍")
                        .font(.title2)
                }
            }
            
            Text(location.hours)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Accepts:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(location.accepts, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            Button("Get Directions") {
                // TODO: Open maps app
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
