import SwiftUI
import SwiftData

struct UnitOfMeasureListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \UnitOfMeasure.name) private var units: [UnitOfMeasure]
    @State private var isPresentingNew = false
    @State private var newName = ""
    @State private var editingUnit: UnitOfMeasure?

    var body: some View {
        List {
            ForEach(units) { unit in
                Button {
                    editingUnit = unit
                } label: {
                    Text(unit.name)
                        .foregroundStyle(.primary)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.plain)
        .navigationTitle("Jedinice mjere")
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
            if units.isEmpty {
                ContentUnavailableView(
                    "Nema jedinica mjere",
                    systemImage: "ruler",
                    description: Text("Dodajte npr. kom, kg, l, m.")
                )
            }
        }
        .alert("Nova jedinica mjere", isPresented: $isPresentingNew) {
            TextField("Naziv", text: $newName)
            Button("Spremi") { addUnit() }
            Button("Odustani", role: .cancel) {}
        }
        .sheet(item: $editingUnit) { unit in
            RenameSheet(title: "Uredi jedinicu mjere", name: unit.name) { newValue in
                unit.name = newValue
                try? context.save()
            } onDelete: {
                context.delete(unit)
                try? context.save()
            }
        }
    }

    private func addUnit() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        context.insert(UnitOfMeasure(name: trimmed))
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(units[index])
        }
        try? context.save()
    }
}
