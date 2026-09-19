import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var isPresentingNew = false
    @State private var newName = ""
    @State private var editingCategory: Category?

    var body: some View {
        List {
            ForEach(categories) { category in
                Button {
                    editingCategory = category
                } label: {
                    Text(category.name)
                        .foregroundStyle(.primary)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .navigationTitle("Kategorije")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    newName = ""
                    isPresentingNew = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if categories.isEmpty {
                ContentUnavailableView(
                    "Nema kategorija",
                    systemImage: "tag",
                    description: Text("Dodajte npr. Piće, Hrana, Higijena.")
                )
            }
        }
        .alert("Nova kategorija", isPresented: $isPresentingNew) {
            TextField("Naziv", text: $newName)
            Button("Spremi") { addCategory() }
            Button("Odustani", role: .cancel) {}
        }
        .sheet(item: $editingCategory) { category in
            RenameSheet(title: "Uredi kategoriju", name: category.name) { newValue in
                category.name = newValue
                try? context.save()
            } onDelete: {
                context.delete(category)
                try? context.save()
            }
        }
    }

    private func addCategory() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        context.insert(Category(name: trimmed))
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(categories[index])
        }
        try? context.save()
    }
}
