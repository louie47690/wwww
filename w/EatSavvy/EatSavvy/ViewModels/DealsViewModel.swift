import Foundation
import Combine

class DealsViewModel: ObservableObject {
    @Published var deals: [Deal] = []
    @Published var favoriteDeals: Set<UUID> = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load favorites from UserDefaults
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteDeals") as? [String] {
            favoriteDeals = Set(savedFavorites.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func fetchNearbyDeals(latitude: Double, longitude: Double) {
        isLoading = true
        
        APIService.shared.fetchNearbyDeals(latitude: latitude, longitude: longitude)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] deals in
                    self?.deals = deals
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite(dealId: UUID) {
        if favoriteDeals.contains(dealId) {
            favoriteDeals.remove(dealId)
        } else {
            favoriteDeals.insert(dealId)
        }
        
        // Save to UserDefaults
        let favoritesArray = Array(favoriteDeals.map { $0.uuidString })
        UserDefaults.standard.set(favoritesArray, forKey: "FavoriteDeals")
    }
    
    func getFavoriteDeals() -> [Deal] {
        return deals.filter { favoriteDeals.contains($0.id) }
    }
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
