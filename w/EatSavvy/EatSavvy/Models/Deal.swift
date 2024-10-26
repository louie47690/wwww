import Foundation

struct Deal: Identifiable, Codable {
    let id: UUID
    let restaurantId: UUID
    let title: String
    let description: String
    let discount: String
    let expirationDate: Date
    let terms: String
    let isExclusive: Bool
    let dealType: DealType
    
    enum DealType: String, Codable {
        case percentage
        case fixedAmount
        case buyOneGetOne
        case special
    }
}

struct Restaurant: Identifiable, Codable {
    let id: UUID
    let name: String
    let cuisine: [CuisineType]
    let address: Address
    let rating: Double
    let priceRange: PriceRange
    let coordinates: Coordinates
    
    enum CuisineType: String, Codable {
        case american
        case italian
        case chinese
        case mexican
        case japanese
        case indian
        case other
    }
    
    enum PriceRange: String, Codable {
        case budget = "$"
        case moderate = "$$"
        case expensive = "$$$"
        case luxury = "$$$$"
    }
}

struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}
