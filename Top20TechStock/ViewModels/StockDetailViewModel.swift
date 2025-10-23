import Foundation

@MainActor
final class StockDetailViewModel: ObservableObject {
    @Published var data: [StockDataPoint] = []
    @Published var range: StockRange = .week

    private let symbol: String
    private let service: YahooStockService

    init(symbol: String, service: YahooStockService = YahooStockService()) {
        self.symbol = symbol
        self.service = service
    }

    func load() async {
        do {
            data = try await service.fetchHistory(symbol: symbol, range: range)
        } catch {
            print("❌ Failed to fetch history for \(symbol):", error)
        }
    }

    func setRange(_ newRange: StockRange) async {
        range = newRange
        await load()
    }
}
