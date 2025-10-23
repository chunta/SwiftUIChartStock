import SwiftUI

@MainActor
final class StockListViewModel: ObservableObject {
    @Published var stocks: [StockQuote] = []
    @Published var isLoading = false

    private let service: StockService

    // 換成真實 API
    init(service: StockService = YahooStockService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            stocks = try await service.fetchTopStocks()
        } catch {
            print("❌ load error:", error)
        }
    }
}
