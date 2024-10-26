import Foundation
import Combine

class UserPreferencesViewModel: ObservableObject {
    @Published var selectedCuisines: Set<Restaurant.CuisineType> = []
    @Published var maxPriceRange: Restaurant.PriceRange = .luxury
    @Published var dietaryPreferences: Set<DietaryPreference> = []
    @Published var notificationsEnabled = true
    @Published var searchRadius: Double = 5.0 // miles
    
    enum DietaryPreference: String, CaseIterable {
        case vegetarian
        case vegan
        case glutenFree
        case dairyFree
        case nutFree
        
        var displayName: String {
            switch self {
            case .glutenFree: return "Gluten Free"
            case .dairyFree: return "Dairy Free"
            case .nutFree: return "Nut Free"
            default: return rawValue.capitalized
            }
        }
    }
    
    func toggleCuisine(_ cuisine: Restaurant.CuisineType) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }
    
    func toggleDietaryPreference(_ preference: DietaryPreference) {
        if dietaryPreferences.contains(preference) {
            dietaryPreferences.remove(preference)
        } else {
            dietaryPreferences.insert(preference)
        }
    }
    
    func savePreferences() {
        // In a real app, this would persist preferences to UserDefaults or a backend
        print("Preferences saved")
    }
}
