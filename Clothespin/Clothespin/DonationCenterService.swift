import Foundation
import CoreLocation
import MapKit
import SwiftUI

enum LocationType: String, CaseIterable {
    case donationCenter = "Donation Centers"
    case thriftStore = "Thrift Stores"
    case popUp = "Pop-ups & Markets"
    case consignment = "Consignment"
    case clothingSwap = "Clothing Swaps"
    case repairShop = "Repair & Alteration"
    
    var searchTerms: [String] {
        switch self {
        case .donationCenter:
            return ["goodwill", "salvation army", "donation center", "thrift donation"]
        case .thriftStore:
            return ["thrift store", "vintage shop", "second hand", "used clothing"]
        case .popUp:
            return ["pop up", "flea market", "clothing swap", "market", "bazaar"]
        case .consignment:
            return ["consignment", "designer resale", "luxury resale", "buffalo exchange"]
        case .clothingSwap:
            return ["clothing swap", "swap meet", "clothing exchange", "community swap"]
        case .repairShop:
            return ["tailor", "alterations", "clothing repair", "sewing", "dry cleaner"]
        }
    }
    
    var icon: String {
        switch self {
        case .donationCenter: return "heart.fill"
        case .thriftStore: return "bag.fill"
        case .popUp: return "calendar"
        case .consignment: return "star.fill"
        case .clothingSwap: return "arrow.triangle.2.circlepath"
        case .repairShop: return "scissors"
        }
    }
    
    var color: Color {
        switch self {
        case .donationCenter: return .primary
        case .thriftStore: return .sageGreen
        case .popUp: return .accent
        case .consignment: return .secondary
        case .clothingSwap: return .warmBrown
        case .repairShop: return .rust
        }
    }
}

struct DonationCenterService {
    
    // Search for sustainable fashion locations near a location
    static func searchLocations(near location: CLLocation, type: LocationType? = nil, completion: @escaping ([DonationLocation]) -> Void) {
        // Use simpler, more specific search queries for better results
        let searchQueries: [String]
        
        if let type = type {
            // Single type search with specific terms
            searchQueries = type.searchTerms.map { "\"\($0)\"" }
        } else {
            // Multiple targeted searches for different types
            searchQueries = [
                "thrift store",
                "goodwill",
                "donation center", 
                "consignment shop",
                "vintage clothing",
                "salvation army"
            ]
        }
        
        print("🔍 Searching for locations near: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("🔍 Search queries: \(searchQueries)")
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchQueries.first ?? "thrift store"
        searchRequest.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Search error: \(error.localizedDescription)")
                    print("❌ Error details: \(error)")
                    // Fallback to enhanced mock data
                    completion(getEnhancedMockLocations(near: location, type: type))
                    return
                }
                
                guard let response = response else {
                    print("❌ No response from MKLocalSearch")
                    completion(getEnhancedMockLocations(near: location, type: type))
                    return
                }
                
                print("✅ Found \(response.mapItems.count) real locations from MKLocalSearch")
                
                let locations = response.mapItems.compactMap { mapItem -> DonationLocation? in
                    guard let name = mapItem.name,
                          let placemark = mapItem.placemark.location else { return nil }
                    
                    let address = formatAddress(from: mapItem.placemark)
                    let distance = location.formattedDistance(from: placemark)
                    let locationType = determineLocationType(for: name)
                    
                    return DonationLocation(
                        name: name,
                        address: address,
                        distance: distance,
                        coordinate: placemark.coordinate,
                        hours: "Hours vary - call for details",
                        accepts: getAcceptedItems(for: name, type: locationType),
                        type: locationType
                    )
                }
                
                // Sort by distance
                let sortedLocations = locations.sorted { location1, location2 in
                    let distance1 = parseDistance(location1.distance)
                    let distance2 = parseDistance(location2.distance)
                    return distance1 < distance2
                }
                
                // If we got real results, use them; otherwise fall back to mock data
                if sortedLocations.isEmpty {
                    print("⚠️ No real locations found, using mock data")
                    completion(getEnhancedMockLocations(near: location, type: type))
                } else {
                    print("✅ Using \(sortedLocations.count) real locations")
                    completion(sortedLocations)
                }
            }
        }
    }
    
    // Perform multiple searches for different location types when "All" is selected
    static func searchAllLocationTypes(near location: CLLocation, completion: @escaping ([DonationLocation]) -> Void) {
        let searchTerms = ["thrift store", "goodwill", "consignment", "donation center"]
        var allLocations: [DonationLocation] = []
        let group = DispatchGroup()
        
        for searchTerm in searchTerms {
            group.enter()
            
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchTerm
            searchRequest.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                defer { group.leave() }
                
                if let response = response {
                    let locations = response.mapItems.compactMap { mapItem -> DonationLocation? in
                        guard let name = mapItem.name,
                              let placemark = mapItem.placemark.location else { return nil }
                        
                        let address = formatAddress(from: mapItem.placemark)
                        let distance = location.formattedDistance(from: placemark)
                        let locationType = determineLocationType(for: name)
                        
                        return DonationLocation(
                            name: name,
                            address: address,
                            distance: distance,
                            coordinate: placemark.coordinate,
                            hours: "Hours vary - call for details",
                            accepts: getAcceptedItems(for: name, type: locationType),
                            type: locationType
                        )
                    }
                    
                    DispatchQueue.main.async {
                        allLocations.append(contentsOf: locations)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            // Remove duplicates and sort by distance
            let uniqueLocations = Array(Set(allLocations.map { $0.name })).compactMap { name in
                allLocations.first { $0.name == name }
            }
            
            let sortedLocations = uniqueLocations.sorted { location1, location2 in
                let distance1 = parseDistance(location1.distance)
                let distance2 = parseDistance(location2.distance)
                return distance1 < distance2
            }
            
            if sortedLocations.isEmpty {
                print("⚠️ No real locations found from multiple searches, using mock data")
                completion(getEnhancedMockLocations(near: location, type: nil))
            } else {
                print("✅ Found \(sortedLocations.count) real locations from multiple searches")
                completion(sortedLocations)
            }
        }
    }
    
    // Enhanced mock data with diverse location types
    private static func getEnhancedMockLocations(near location: CLLocation, type: LocationType?) -> [DonationLocation] {
        let allLocations = [
            // Donation Centers
            DonationLocation(
                name: "Goodwill San Francisco",
                address: "123 Market St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7849, longitude: -122.4094)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                hours: "Mon-Sat: 9AM-8PM, Sun: 10AM-7PM",
                accepts: ["Clothing", "Shoes", "Accessories", "Household Items"],
                type: .donationCenter
            ),
            DonationLocation(
                name: "Salvation Army Family Store",
                address: "456 Mission St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7649, longitude: -122.4294)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                hours: "Mon-Fri: 8AM-6PM, Sat: 9AM-5PM",
                accepts: ["Clothing", "Household Items", "Furniture"],
                type: .donationCenter
            ),
            
            // Thrift Stores
            DonationLocation(
                name: "Buffalo Exchange",
                address: "789 Valencia St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7549, longitude: -122.4394)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4394),
                hours: "Mon-Sun: 10AM-8PM",
                accepts: ["Vintage Clothing", "Designer Items", "Accessories"],
                type: .consignment
            ),
            DonationLocation(
                name: "Crossroads Trading",
                address: "1901 Fillmore St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7849, longitude: -122.4324)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4324),
                hours: "Mon-Sat: 11AM-8PM, Sun: 12PM-7PM",
                accepts: ["Designer Clothing", "Vintage Items", "Shoes"],
                type: .consignment
            ),
            DonationLocation(
                name: "Community Thrift",
                address: "623 Valencia St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7609, longitude: -122.4214)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7609, longitude: -122.4214),
                hours: "Mon-Sun: 10AM-7PM",
                accepts: ["Clothing", "Books", "Household Items"],
                type: .thriftStore
            ),
            
            // Pop-ups & Markets
            DonationLocation(
                name: "SF Flea Market",
                address: "100 Alemany Blvd, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7209, longitude: -122.4214)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7209, longitude: -122.4214),
                hours: "Sat-Sun: 6AM-3PM",
                accepts: ["Vintage Clothing", "Antiques", "Collectibles"],
                type: .popUp
            ),
            DonationLocation(
                name: "Mission Community Market",
                address: "22nd St & Bartlett, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7549, longitude: -122.4194)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4194),
                hours: "Thurs: 4PM-8PM",
                accepts: ["Local Designer", "Handmade Items", "Vintage"],
                type: .popUp
            ),
            
            // Clothing Swaps
            DonationLocation(
                name: "SF Clothing Swap",
                address: "Various Locations - Check Website",
                distance: "Event-based",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                hours: "Monthly Events",
                accepts: ["Clothing Exchange", "Accessories", "Shoes"],
                type: .clothingSwap
            ),
            
            // Repair & Alteration
            DonationLocation(
                name: "Mission Tailoring",
                address: "2981 Mission St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7509, longitude: -122.4194)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7509, longitude: -122.4194),
                hours: "Mon-Fri: 9AM-6PM, Sat: 10AM-4PM",
                accepts: ["Alterations", "Repairs", "Custom Work"],
                type: .repairShop
            ),
            DonationLocation(
                name: "Sewing Studio SF",
                address: "1847 Union St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7949, longitude: -122.4294)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7949, longitude: -122.4294),
                hours: "Mon-Sat: 10AM-7PM",
                accepts: ["Clothing Repair", "Alterations", "Classes"],
                type: .repairShop
            ),
            
            // More Thrift Stores
            DonationLocation(
                name: "Out of the Closet",
                address: "321 Castro St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7609, longitude: -122.4350)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7609, longitude: -122.4350),
                hours: "Mon-Sun: 9AM-9PM",
                accepts: ["Clothing", "Accessories", "Books", "Electronics"],
                type: .thriftStore
            ),
            DonationLocation(
                name: "Wasteland",
                address: "1660 Haight St, San Francisco, CA",
                distance: location.formattedDistance(from: CLLocation(latitude: 37.7699, longitude: -122.4469)),
                coordinate: CLLocationCoordinate2D(latitude: 37.7699, longitude: -122.4469),
                hours: "Mon-Sun: 11AM-8PM",
                accepts: ["Vintage Designer", "Streetwear", "Accessories"],
                type: .thriftStore
            )
        ]
        
        if let type = type {
            return allLocations.filter { $0.type == type }
        }
        
        return allLocations
    }
    
    // Search for locations in a specific city
    static func searchLocations(in city: String, type: LocationType? = nil, completion: @escaping ([DonationLocation]) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion([])
                return
            }
            
            searchLocations(near: location, type: type, completion: completion)
        }
    }
    
    // Helper functions
    private static func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let streetNumber = placemark.subThoroughfare {
            addressComponents.append(streetNumber)
        }
        if let streetName = placemark.thoroughfare {
            addressComponents.append(streetName)
        }
        if let city = placemark.locality {
            addressComponents.append(city)
        }
        if let state = placemark.administrativeArea {
            addressComponents.append(state)
        }
        
        return addressComponents.joined(separator: " ")
    }
    
    private static func determineLocationType(for businessName: String) -> LocationType {
        let name = businessName.lowercased()
        
        if name.contains("goodwill") || name.contains("salvation army") || name.contains("donation") {
            return .donationCenter
        } else if name.contains("buffalo exchange") || name.contains("crossroads") || name.contains("consignment") {
            return .consignment
        } else if name.contains("flea") || name.contains("market") || name.contains("pop") || name.contains("bazaar") {
            return .popUp
        } else if name.contains("swap") || name.contains("exchange") {
            return .clothingSwap
        } else if name.contains("tailor") || name.contains("sewing") || name.contains("alteration") || name.contains("repair") {
            return .repairShop
        } else {
            return .thriftStore
        }
    }
    
    private static func getAcceptedItems(for businessName: String, type: LocationType) -> [String] {
        switch type {
        case .donationCenter:
            return ["Clothing", "Shoes", "Accessories", "Household Items", "Books"]
        case .thriftStore:
            return ["Vintage Clothing", "Designer Items", "Accessories", "Books"]
        case .consignment:
            return ["Designer Items", "Vintage Clothing", "Shoes", "Handbags"]
        case .popUp:
            return ["Vintage", "Handmade", "Local Designer", "Unique Items"]
        case .clothingSwap:
            return ["Clothing Exchange", "Accessories", "Shoes", "Jewelry"]
        case .repairShop:
            return ["Alterations", "Repairs", "Custom Work", "Dry Cleaning"]
        }
    }
    
    private static func parseDistance(_ distanceString: String) -> Double {
        let cleaned = distanceString.replacingOccurrences(of: " mi", with: "").replacingOccurrences(of: " m", with: "")
        return Double(cleaned) ?? 999.0
    }
}
