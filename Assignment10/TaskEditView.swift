import SwiftUI

/// Used for both creating (task == nil) and editing a task.
struct TaskEditView: View {
    let task: TodoTask?
    let onSave: (_ title: String, _ description: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @FocusState private var titleFocused: Bool

    init(task: TodoTask?, onSave: @escaping (String, String) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.description ?? "")
    }

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    fieldBlock(label: "Title", icon: "textformat") {
                        TextField("e.g. Finish lab report", text: $title)
                            .focused($titleFocused)
                            .padding(14)
                            .background(fieldBackground)
                    }

                    fieldBlock(label: "Description", icon: "text.alignleft") {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 160)
                                .padding(10)
                            if description.isEmpty {
                                Text("Add some details (optional)")
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                        .background(fieldBackground)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: save) {
                    Text(task == nil ? "Add Task" : "Save Changes")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Group {
                                if trimmedTitle.isEmpty { Color.gray.opacity(0.35) }
                                else { Theme.gradient }
                            },
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }
                .disabled(trimmedTitle.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.bar)
            }
        }
        .tint(Theme.accent)
        .onAppear { if task == nil { titleFocused = true } }
    }

    // MARK: Helpers
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func fieldBlock<Content: View>(label: String, icon: String,
                                           @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func save() {
        onSave(trimmedTitle,
               description.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}
