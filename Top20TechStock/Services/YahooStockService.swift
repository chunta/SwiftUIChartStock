import Foundation

protocol StockService {
    func fetchTopStocks() async throws -> [StockQuote]
    func fetchHistory(symbol: String, range: StockRange) async throws -> [StockDataPoint]
}

enum StockRange {
    case week, month, threeMonth
}

final class YahooStockService: StockService {
    func fetchTopStocks() async throws -> [StockQuote] {
        let tickers = ["AAPL", "MSFT", "NVDA", "AMZN", "GOOG", "META", "TSLA", "ORCL", "AMD", "NFLX"]
        var quotes: [StockQuote] = []
        for symbol in tickers {
            if let q = try? await fetchLatest(symbol: symbol) {
                quotes.append(q)
            }
        }
        return quotes
    }

    func fetchHistory(symbol: String, range: StockRange) async throws -> [StockDataPoint] {
        let rangeString: String
        switch range {
        case .week: rangeString = "7d"
        case .month: rangeString = "1mo"
        case .threeMonth: rangeString = "3mo"
        }

        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=\(rangeString)&interval=1d"
        let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
        let decoded = try JSONDecoder().decode(YahooChartResponse.self, from: data)
        return decoded.toDataPoints()
    }

    private func fetchLatest(symbol: String) async throws -> StockQuote {
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=7d&interval=1d"
        let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
        let decoded = try JSONDecoder().decode(YahooChartResponse.self, from: data)

        let points = decoded.toDataPoints()
        guard let last = points.last else {
            throw URLError(.badServerResponse)
        }

        return StockQuote(
            symbol: symbol,
            company: symbol,
            latestPrice: last.price,
            series: points
        )
    }
}
