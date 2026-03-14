//
//  LocationFilterSheetView.swift
//  Queryable
//

import SwiftUI

struct LocationFilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var photoSearcher: PhotoSearcher
    @State private var draftLocation: String = ""
    @State private var draftRadius: Double = 25
    @State private var draftEnabled: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Enable Location Filter", isOn: $draftEnabled)

                Section("Location") {
                    TextField("City, town, or place", text: $draftLocation)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)

                    HStack {
                        Text("Radius")
                        Spacer()
                        Text("\(Int(draftRadius)) km")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $draftRadius, in: 1...250, step: 1)
                }

                if let error = photoSearcher.locationFilterErrorMessage, draftEnabled {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .navigationTitle("Location Filter")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        photoSearcher.isLocationFilterEnabled = draftEnabled
                        photoSearcher.locationQuery = draftLocation
                        photoSearcher.locationRadiusKM = draftRadius
                        photoSearcher.locationFilterErrorMessage = nil
                        dismiss()
                    }
                }
            }
            .onAppear {
                draftEnabled = photoSearcher.isLocationFilterEnabled
                draftLocation = photoSearcher.locationQuery
                draftRadius = photoSearcher.locationRadiusKM
            }
        }
    }
}
