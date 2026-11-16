//
//  RootView.swift
//  Assignment10
//
//  Created by macos on 4/11/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.user != nil {
            TaskListView()
        } else {
            LoginView()
        }
    }
}
