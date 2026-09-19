import SwiftUI

/// Minimal add/edit sheet for single-field code lists (units of measure,
/// categories): spec sections 4 and 5 explicitly say these don't need
/// complex screens.
struct RenameSheet: View {
    let title: String
    @State var name: String
    let onSave: (String) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Naziv", text: $name)

                Button("Obriši", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Odustani") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spremi") {
                        onSave(name)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
