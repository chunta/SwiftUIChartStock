import SwiftUI
import Charts

struct StockDetailView: View {
    let symbol: String
    @StateObject private var vm: StockDetailViewModel

    init(symbol: String) {
        self.symbol = symbol
        _vm = StateObject(wrappedValue: StockDetailViewModel(symbol: symbol))
    }

    var body: some View {
        VStack {
            Picker("Range", selection: $vm.range) {
                Text("7D").tag(StockRange.week)
                Text("30D").tag(StockRange.month)
                Text("3M").tag(StockRange.threeMonth)
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: vm.range) { oldValue, newValue in
                Task { await vm.setRange(newValue) }
            }
            Chart(vm.data) {
                LineMark(
                    x: .value("Date", $0.date),
                    y: .value("Price", $0.price)
                )
                LineMark(
                    x: .value("Date", $0.date),
                    y: .value("Price", $0.price)
                )
            }
            .frame(height: 300)
            .padding()

            Spacer()
        }
        .navigationTitle(symbol)
        .task {
            await vm.load()
        }
    }
}

// MARK: - 🔹 Preview
struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // 建立假資料
        let mockData: [StockDataPoint] = {
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            var last = 200.0
            return (0..<7).map { i in
                let d = Calendar.current.date(byAdding: .day, value: i, to: start)!
                last += Double.random(in: -2...2)
                return StockDataPoint(date: d, price: last)
            }
        }()

        // 建立一個假的 ViewModel
        let mockVM = StockDetailViewModel(symbol: "AAPL")
        mockVM.data = mockData

        return NavigationStack {
            StockDetailView(symbol: "AAPL")
                .environmentObject(mockVM) // 或直接設定 StateObject
        }
        .previewDisplayName("AAPL 7-Day Trend")
    }
}
