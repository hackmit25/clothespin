import SwiftUI

struct StatsView: View {
    @StateObject private var itemManager = ClothingItemManager()
    
    // Mock data for insights
    private var clothingTypeData: [(String, Double, Color)] {
        [
            ("Tops", 35, Color.sageGreen),
            ("Bottoms", 25, Color.darkGreen),
            ("Dresses", 20, Color.warmBrown),
            ("Outerwear", 15, Color.rust),
            ("Accessories", 5, Color.sageGreen.opacity(0.7))
        ]
    }
    
    private var sustainabilityScore: Int {
        let sustainableWears = brandData.filter { $0.2 }.reduce(0) { $0 + $1.1 }
        let totalWears = brandData.reduce(0) { $0 + $1.1 }
        return totalWears > 0 ? Int((Double(sustainableWears) / Double(totalWears)) * 100) : 0
    }
    
    private var donationCandidates: [(String, Int, String)] {
        [
            ("Items worn < 3 times", 5, "Ready to donate"),
            ("Items not worn in 30+ days", 3, "Consider donating"),
            ("Items never worn", 2, "Donate immediately")
        ]
    }
    
    private var environmentalImpact: [(String, String, Color)] {
        [
            ("CO₂ Saved", "127 kg", Color.sageGreen),
            ("Water Saved", "8,400 L", Color.darkGreen),
            ("Waste Diverted", "12 items", Color.warmBrown)
        ]
    }
    
    private var brandData: [(String, Int, Bool, Color)] {
        [
            ("Patagonia", 15, true, Color.sageGreen),      // Sustainable
            ("Everlane", 12, true, Color.sageGreen),       // Sustainable
            ("Reformation", 8, true, Color.darkGreen),     // Sustainable
            ("Zara", 20, false, Color.rust),               // Fast fashion
            ("H&M", 18, false, Color.rust),                // Fast fashion
            ("Uniqlo", 10, false, Color.warmBrown),        // Mixed
            ("Levi's", 14, true, Color.sageGreen),         // Sustainable
            ("Nike", 16, false, Color.rust),               // Mixed
            ("Eileen Fisher", 6, true, Color.darkGreen),   // Sustainable
            ("Forever 21", 4, false, Color.rust)           // Fast fashion
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Clothing Type Distribution - Pie Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("clothing type distribution")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.darkGreen)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Pie Chart on the left
                            ZStack {
                                // Pie Chart
                                ForEach(Array(clothingTypeData.enumerated()), id: \.offset) { index, data in
                                    let startAngle = clothingTypeData.prefix(index).reduce(0) { $0 + $1.1 * 3.6 }
                                    let endAngle = startAngle + data.1 * 3.6
                                    
                                    PieSlice(startAngle: .degrees(startAngle), endAngle: .degrees(endAngle))
                                        .fill(data.2)
                                        .frame(width: 160, height: 160)
                                }
                                
                                // Center text
                                VStack(spacing: 2) {
                                    Text("\(itemManager.items.count)")
                                        .font(.custom("Poppins-Bold", size: 18))
                                        .foregroundColor(.white)
                                    Text("total items")
                                        .font(.custom("Poppins-Regular", size: 9))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 160, height: 160)
                            
                            // Legend on the right
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(clothingTypeData.enumerated()), id: \.offset) { index, data in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(data.2)
                                            .frame(width: 12, height: 12)
                                        
                                        Text(data.0)
                                            .font(.custom("Poppins-Medium", size: 14))
                                            .foregroundColor(.textPrimary)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(data.1))%")
                                            .font(.custom("Poppins-SemiBold", size: 14))
                                            .foregroundColor(.textPrimary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.border, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Sustainability Score
                    VStack(alignment: .leading, spacing: 16) {
                        Text("sustainability score")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.darkGreen)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Score Circle
                            ZStack {
                                Circle()
                                    .stroke(Color.sageGreen.opacity(0.3), lineWidth: 8)
                                    .frame(width: 100, height: 100)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(sustainabilityScore) / 100)
                                    .stroke(Color.sageGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text("\(sustainabilityScore)%")
                                        .font(.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(.darkGreen)
                                    Text("sustainable")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your wardrobe is \(sustainabilityScore >= 70 ? "very" : sustainabilityScore >= 50 ? "moderately" : "not very") sustainable")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.textPrimary)
                                
                                Text(sustainabilityScore >= 70 ? "Great job! You're mostly wearing sustainable brands." : sustainabilityScore >= 50 ? "Good progress! Try to wear more sustainable brands." : "Consider donating fast fashion items and buying sustainable alternatives.")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.border, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Donation Candidates
                    VStack(alignment: .leading, spacing: 16) {
                        Text("donation opportunities")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.darkGreen)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(donationCandidates.enumerated()), id: \.offset) { index, data in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(data.0)
                                            .font(.custom("Poppins-Medium", size: 16))
                                            .foregroundColor(.textPrimary)
                                        
                                        Text(data.2)
                                            .font(.custom("Poppins-Regular", size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(data.1)")
                                        .font(.custom("Poppins-Bold", size: 24))
                                        .foregroundColor(.rust)
                                }
                                .padding()
                                .background(Color.rust.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.border, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Environmental Impact
                    VStack(alignment: .leading, spacing: 16) {
                        Text("environmental impact")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.darkGreen)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(Array(environmentalImpact.enumerated()), id: \.offset) { index, data in
                                VStack(spacing: 8) {
                                    Text(data.1)
                                        .font(.custom("Poppins-Bold", size: 20))
                                        .foregroundColor(data.2)
                                    
                                    Text(data.0)
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(data.2.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.border, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Brand Sustainability - Bar Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("brand sustainability")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.darkGreen)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                ForEach(Array(brandData.sorted(by: { $0.1 > $1.1 }).enumerated()), id: \.offset) { index, data in
                                    HStack(spacing: 12) {
                                        // Brand name with sustainability indicator
                                        HStack(spacing: 6) {
                                            Text(data.0)
                                                .font(.custom("Poppins-Medium", size: 14))
                                                .foregroundColor(.textPrimary)
                                            
                                            // Sustainability indicator
                                            Image(systemName: data.2 ? "leaf.fill" : "exclamationmark.triangle.fill")
                                                .font(.caption)
                                                .foregroundColor(data.2 ? .green : .orange)
                                        }
                                        .frame(width: 100, alignment: .leading)
                                        
                                        // Bar chart
                                        GeometryReader { geometry in
                                            HStack {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(data.3)
                                                    .frame(width: geometry.size.width * CGFloat(data.1) / 25)
                                                
                                                Spacer()
                                            }
                                        }
                                        .frame(height: 20)
                                        
                                        // Wear count
                                        Text("\(data.1)")
                                            .font(.custom("Poppins-SemiBold", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .frame(width: 30, alignment: .trailing)
                                    }
                                }
                            }
                            
                            // Legend
                            HStack(spacing: 20) {
                                HStack(spacing: 6) {
                                    Image(systemName: "leaf.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text("Sustainable")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.textPrimary)
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text("Fast Fashion")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(.textPrimary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.border, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .background(Color.white)
            .navigationTitle("insights")
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
        }
    }
}

struct StatsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
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
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(value)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            Text(description)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct RecommendationCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .shadow(color: Color.border, radius: 2, x: 0, y: 1)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
