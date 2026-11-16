import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = TaskViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TodoTask?

    private var completedCount: Int { vm.tasks.filter { $0.isCompleted }.count }

    var body: some View {
        NavigationStack {
            Group {
                if vm.tasks.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        progressCard
                        taskList
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vm.stop(); auth.signOut()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .tint(Theme.accent)
                }
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                addButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
            }
            .sheet(isPresented: $showingAdd) {
                TaskEditView(task: nil) { title, desc in vm.add(title: title, description: desc) }
            }
            .sheet(item: $editingTask) { task in
                TaskEditView(task: task) { title, desc in
                    var t = task
                    t.title = title
                    t.description = desc
                    vm.update(t)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
        .tint(Theme.accent)
        .onAppear { if let uid = auth.user?.uid { vm.start(uid: uid) } }
        .onDisappear { vm.stop() }
    }

    // MARK: Pieces

    private var progressCard: some View {
        let total = vm.tasks.count
        let fraction = total == 0 ? 0 : Double(completedCount) / Double(total)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(completedCount == total ? "All done 🎉" : "\(total - completedCount) left to do")
                    .font(.headline)
                Spacer()
                Text("\(completedCount)/\(total)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: fraction)
                .tint(Theme.accent)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
                .animation(.easeInOut, value: fraction)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var taskList: some View {
        List {
            ForEach(vm.tasks) { task in
                TaskRow(task: task) { vm.toggle(task) }
                    .contentShape(Rectangle())
                    .onTapGesture { editingTask = task }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .swipeActions {
                        Button(role: .destructive) { vm.delete(task) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.default, value: vm.tasks)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checklist")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 96, height: 96)
                .background(Theme.accent.opacity(0.12), in: Circle())
            Text("No tasks yet").font(.title3.weight(.semibold))
            Text("Tap the + button to add your first task.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Theme.gradient, in: Circle())
                .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 6)
        }
        .accessibilityLabel("Add task")
    }
}

// MARK: - Row
private struct TaskRow: View {
    let task: TodoTask
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundStyle(task.isCompleted ? AnyShapeStyle(Theme.gradient)
                                                      : AnyShapeStyle(Color.secondary.opacity(0.5)))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}
