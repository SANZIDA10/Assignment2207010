//
//  TodoTask.swift
//  Assignment10
//
//  Created by macos on 4/11/26.
//


import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date

    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         isCompleted: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    /// Firestore document -> TodoTask
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String else { return nil }
        self.id = document.documentID
        self.title = title
        self.description = data["description"] as? String ?? ""
        self.isCompleted = data["isCompleted"] as? Bool ?? false
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    /// TodoTask -> Firestore data
    var firestoreData: [String: Any] {
        [
            "title": title,
            "description": description,
            "isCompleted": isCompleted,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}
