import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("📍 Accuracy: \(location.horizontalAccuracy)m")
        
        // Update region to center on user's location
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Location authorization changed to: \(status.rawValue)")
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized, starting updates...")
            startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Location access denied")
        case .notDetermined:
            print("❓ Location not determined, requesting permission...")
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

// Helper functions for distance calculations
extension CLLocation {
    func distanceFrom(_ location: CLLocation) -> CLLocationDistance {
        return self.distance(from: location)
    }
    
    func formattedDistance(from location: CLLocation) -> String {
        let distance = distanceFrom(location)
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            let miles = distance * 0.000621371 // Convert meters to miles
            return String(format: "%.1f mi", miles)
        }
    }
}
