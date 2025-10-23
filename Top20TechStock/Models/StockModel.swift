import Foundation

struct StockDataPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let price: Double
}

struct StockQuote: Identifiable, Hashable {
    let id = UUID()
    let symbol: String
    let company: String
    let latestPrice: Double
    let series: [StockDataPoint]
}

struct YahooChartResponse: Decodable {
    let chart: Chart

    struct Chart: Decodable {
        let result: [Result]
    }

    struct Result: Decodable {
        let timestamp: [TimeInterval]?
        let indicators: Indicators
    }

    struct Indicators: Decodable {
        let quote: [Quote]
    }

    struct Quote: Decodable {
        let close: [Double?]
    }

    func toDataPoints() -> [StockDataPoint] {
        guard let result = chart.result.first,
              let timestamps = result.timestamp else { return [] }
        let closes = result.indicators.quote.first?.close ?? []

        var points: [StockDataPoint] = []
        for (idx, ts) in timestamps.enumerated() {
            if let price = closes[idx] {
                let date = Date(timeIntervalSince1970: ts)
                points.append(StockDataPoint(date: date, price: price))
            }
        }
        return points
    }
}
