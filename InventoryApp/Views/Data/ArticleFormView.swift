import SwiftUI
import SwiftData

struct ArticleFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \UnitOfMeasure.name) private var units: [UnitOfMeasure]
    @Query(sort: \Category.name) private var categories: [Category]

    let article: Article?

    @State private var name: String = ""
    @State private var code: String = ""
    @State private var selectedUnit: UnitOfMeasure?
    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            Form {
                Section("Osnovni podaci") {
                    TextField("Naziv", text: $name)
                    TextField("Šifra", text: $code)
                }

                Section("Jedinica mjere") {
                    Picker("Jedinica mjere", selection: $selectedUnit) {
                        Text("Nije odabrano").tag(UnitOfMeasure?.none)
                        ForEach(units) { unit in
                            Text(unit.name).tag(Optional(unit))
                        }
                    }
                }

                Section("Kategorija") {
                    Picker("Kategorija", selection: $selectedCategory) {
                        Text("Nije odabrano").tag(Category?.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }

                if article != nil {
                    Section {
                        Button("Obriši artikl", role: .destructive) {
                            deleteAndDismiss()
                        }
                    }
                }
            }
            .navigationTitle(article == nil ? "Novi artikl" : "Uredi artikl")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Odustani") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spremi") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: populateIfEditing)
        }
    }

    private func populateIfEditing() {
        guard let article else { return }
        name = article.name
        code = article.code
        selectedUnit = article.unitOfMeasure
        selectedCategory = article.category
    }

    private func save() {
        if let article {
            article.name = name
            article.code = code
            article.unitOfMeasure = selectedUnit
            article.category = selectedCategory
        } else {
            let newArticle = Article(code: code, name: name, unitOfMeasure: selectedUnit, category: selectedCategory)
            context.insert(newArticle)
        }
        try? context.save()
        dismiss()
    }

    private func deleteAndDismiss() {
        if let article {
            context.delete(article)
            try? context.save()
        }
        dismiss()
    }
}
