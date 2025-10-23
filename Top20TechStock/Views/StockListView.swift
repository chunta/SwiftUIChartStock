import SwiftUI

struct StockListView: View {
    @StateObject private var vm = StockListViewModel()

    var body: some View {
        NavigationStack {
            List(vm.stocks) { stock in
                NavigationLink(destination: StockDetailView(symbol: stock.symbol)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stock.symbol).font(.headline)
                            Text(stock.company).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        SparklineView(series: stock.series)
                        Text(stock.latestPrice, format: .number.precision(.fractionLength(2)))
                            .frame(width: 80, alignment: .trailing)
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                   Color.clear.frame(height: 20)
               }
            .navigationTitle("Top Tech Stocks")
            .task {
                await vm.load()
            }
        }
    }
}


struct StockListView_Previews: PreviewProvider {
    static func makeSeries(_ base: Double = 120, _ days: Int = 7) -> [StockDataPoint] {
        let start = Calendar.current.date(byAdding: .day, value: -days+1, to: Date())!
        var last = base
        return (0..<days).map { i in
            let d = Calendar.current.date(byAdding: .day, value: i, to: start)!
            last = max(1, last + Double.random(in: -2...2))
            return StockDataPoint(date: d, price: last)
        }
    }

    static var previews: some View {
        let vm = StockListViewModel()
        vm.stocks = [
            StockQuote(symbol: "AAPL", company: "Apple Inc.", latestPrice: 229.44, series: makeSeries(225)),
            StockQuote(symbol: "MSFT", company: "Microsoft", latestPrice: 413.21, series: makeSeries(410)),
            StockQuote(symbol: "NVDA", company: "NVIDIA", latestPrice: 875.12, series: makeSeries(860))
        ]
        return NavigationStack {
            List(vm.stocks) { s in
                HStack {
                    Text(s.symbol); Spacer()
                    Text(String(format: "%.2f", s.latestPrice))
                }
            }
            .navigationTitle("Tech Stocks (Preview)")
        }
        .previewDisplayName("StockListView – Preview with series")
    }
}
