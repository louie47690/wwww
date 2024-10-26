import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var dealsViewModel = DealsViewModel()
    @StateObject private var userPreferences = UserPreferencesViewModel()
    
    var body: some View {
        TabView {
            DealsListView()
                .tabItem {
                    Label("Deals", systemImage: "tag.fill")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            PreferencesView()
                .tabItem {
                    Label("Preferences", systemImage: "gear")
                }
        }
        .environmentObject(locationManager)
        .environmentObject(dealsViewModel)
        .environmentObject(userPreferences)
    }
}

struct DealsListView: View {
    @EnvironmentObject var dealsViewModel: DealsViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                if dealsViewModel.isLoading {
                    ProgressView("Finding deals nearby...")
                } else {
                    List(dealsViewModel.deals) { deal in
                        NavigationLink(destination: DealDetailView(deal: deal)) {
                            DealRowView(deal: deal)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Deals")
            .toolbar {
                Button(action: {
                    if let location = locationManager.userLocation {
                        dealsViewModel.fetchNearbyDeals(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

struct DealRowView: View {
    let deal: Deal
    @EnvironmentObject var dealsViewModel: DealsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(deal.title)
                .font(.headline)
            
            Text(deal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(deal.discount)
                    .font(.system(.caption, design: .rounded))
                    .padding(4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                if deal.isExclusive {
                    Text("Exclusive")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
                
                Button(action: {
                    dealsViewModel.toggleFavorite(dealId: deal.id)
                }) {
                    Image(systemName: dealsViewModel.favoriteDeals.contains(deal.id) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct DealDetailView: View {
    let deal: Deal
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(deal.title)
                    .font(.title)
                    .bold()
                
                Text(deal.description)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Expires \(deal.expirationDate.formatted())", systemImage: "clock")
                    
                    Text("Terms & Conditions")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(deal.terms)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FavoritesView: View {
    @EnvironmentObject var dealsViewModel: DealsViewModel
    
    var body: some View {
        NavigationView {
            List(dealsViewModel.getFavoriteDeals()) { deal in
                NavigationLink(destination: DealDetailView(deal: deal)) {
                    DealRowView(deal: deal)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

struct PreferencesView: View {
    @EnvironmentObject var userPreferences: UserPreferencesViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Cuisines")) {
                    ForEach(Restaurant.CuisineType.allCases, id: \.self) { cuisine in
                        Toggle(cuisine.rawValue.capitalized,
                               isOn: Binding(
                                get: { userPreferences.selectedCuisines.contains(cuisine) },
                                set: { _ in userPreferences.toggleCuisine(cuisine) }
                               ))
                    }
                }
                
                Section(header: Text("Dietary Preferences")) {
                    ForEach(UserPreferencesViewModel.DietaryPreference.allCases, id: \.self) { preference in
                        Toggle(preference.displayName,
                               isOn: Binding(
                                get: { userPreferences.dietaryPreferences.contains(preference) },
                                set: { _ in userPreferences.toggleDietaryPreference(preference) }
                               ))
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications",
                           isOn: $userPreferences.notificationsEnabled)
                }
                
                Section(header: Text("Search Radius")) {
                    Slider(value: $userPreferences.searchRadius,
                           in: 1...20,
                           step: 1) {
                        Text("Search Radius")
                    } minimumValueLabel: {
                        Text("1mi")
                    } maximumValueLabel: {
                        Text("20mi")
                    }
                }
            }
            .navigationTitle("Preferences")
        }
    }
}

#Preview {
    ContentView()
}
