import SwiftUI
import Charts

struct SparklineView: View {
    let series: [StockDataPoint]

    var body: some View {
        Chart(series) {
            LineMark(
                x: .value("Date", $0.date),
                y: .value("Price", $0.price)
            )
            .interpolationMethod(.monotone)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 30)
    }
}
