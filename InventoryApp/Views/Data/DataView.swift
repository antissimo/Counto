import SwiftUI

enum DataRoute: Hashable {
    case articles
    case units
    case categories
}

struct DataView: View {
    var body: some View {
        List {
            NavigationLink(value: DataRoute.articles) {
                Label("Artikli", systemImage: "shippingbox")
            }
            NavigationLink(value: DataRoute.units) {
                Label("Jedinice mjere", systemImage: "ruler")
            }
            NavigationLink(value: DataRoute.categories) {
                Label("Kategorije", systemImage: "tag")
            }
        }
        .navigationTitle("Podaci")
        .navigationDestination(for: DataRoute.self) { route in
            switch route {
            case .articles: ArticleListView()
            case .units: UnitOfMeasureListView()
            case .categories: CategoryListView()
            }
        }
    }
}
