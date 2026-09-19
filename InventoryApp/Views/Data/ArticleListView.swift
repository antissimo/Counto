import SwiftUI
import SwiftData

struct ArticleListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Article.name) private var articles: [Article]
    @State private var searchText = ""
    @State private var editingArticle: Article?
    @State private var isPresentingNew = false

    private var filtered: [Article] {
        SearchArticlesUseCase.search(searchText, in: articles)
    }

    var body: some View {
        List {
            ForEach(filtered) { article in
                Button {
                    editingArticle = article
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.name)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        Text("Šifra: \(article.code) · \(article.unitOfMeasure?.name ?? "-") · \(article.category?.name ?? "-")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Pretraži artikle")
        .navigationTitle("Artikli")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingNew = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if articles.isEmpty {
                ContentUnavailableView(
                    "Nema artikala",
                    systemImage: "shippingbox",
                    description: Text("Dodajte prvi artikl pomoću + gumba.")
                )
            }
        }
        .sheet(isPresented: $isPresentingNew) {
            ArticleFormView(article: nil)
        }
        .sheet(item: $editingArticle) { article in
            ArticleFormView(article: article)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filtered[index])
        }
        try? context.save()
    }
}
