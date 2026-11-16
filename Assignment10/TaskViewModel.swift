//
//  TaskViewModel.swift
//  Assignment10
//
//  Created by macos on 4/11/26.
//

import Foundation
import FirebaseFirestore

/// Tasks are stored per user at: users/{uid}/tasks/{taskId}
@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var uid: String?

    private var collection: CollectionReference? {
        guard let uid else { return nil }
        return db.collection("users").document(uid).collection("tasks")
    }

    // MARK: - Realtime listener (READ)

    func start(uid: String) {
        stop()
        self.uid = uid
        listener = collection?
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.tasks = snapshot?.documents.compactMap { TodoTask(document: $0) } ?? []
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
        tasks = []
        uid = nil
    }

    // MARK: - CREATE

    func add(title: String, description: String) {
        let task = TodoTask(title: title, description: description)
        collection?.document(task.id).setData(task.firestoreData) { [weak self] error in
            if let error { Task { @MainActor in self?.errorMessage = error.localizedDescription } }
        }
    }

    // MARK: - UPDATE

    func update(_ task: TodoTask) {
        collection?.document(task.id).updateData([
            "title": task.title,
            "description": task.description,
            "isCompleted": task.isCompleted
        ]) { [weak self] error in
            if let error { Task { @MainActor in self?.errorMessage = error.localizedDescription } }
        }
    }

    func toggle(_ task: TodoTask) {
        var t = task
        t.isCompleted.toggle()
        update(t)
    }

    // MARK: - DELETE

    func delete(_ task: TodoTask) {
        collection?.document(task.id).delete { [weak self] error in
            if let error { Task { @MainActor in self?.errorMessage = error.localizedDescription } }
        }
    }
}
