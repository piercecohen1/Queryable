//
//  SearchBarView.swift
//  Queryable
//
//  Created by Ke Fang on 2022/12/14.
//

import SwiftUI

struct SearchBarView: View {
    @FocusState private var inputFocused: Bool
    @FocusState private var locationFocused: Bool
    @ObservedObject var photoSearcher: PhotoSearcher
    @State var searchText: String = ""
    private let showString: LocalizedStringKey = ["My love", "Dark night room with a lamp", "Snow outside the window", "Deep blue", "Cute kitten", "Photos of our gathering", "Beach, waves, sunset", "In car view, car on the road", "Screen display of traffic info", "Selfie in front of mirror", "Cheers"].randomElement()!

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .accessibilityHidden(true)
                TextField(showString, text: $searchText)
                    .multilineTextAlignment(.leading)
                    .focused($inputFocused)
                    .accessibilityAddTraits(.isSearchField)
                    .accessibilityHint(Text("Input your sentences here, then press enter"))
                    .onSubmit {
                        triggerSearch()
                    }
                    .submitLabel(.search)
                if !searchText.isEmpty {
                    Button {
                        self.clearSearch()
                    } label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                            .accessibilityLabel("Clear search")
                    }
                }
                Button {
                    withAnimation {
                        photoSearcher.isLocationFilterActive.toggle()
                        if !photoSearcher.isLocationFilterActive {
                            photoSearcher.locationQuery = ""
                            photoSearcher.locationError = nil
                        }
                    }
                } label: {
                    Image(systemName: photoSearcher.isLocationFilterActive ? "location.fill" : "location")
                        .foregroundColor(photoSearcher.isLocationFilterActive ? .accentColor : Color(UIColor.opaqueSeparator))
                        .accessibilityLabel("Toggle location filter")
                }
            }
            if photoSearcher.isLocationFilterActive {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                        .accessibilityHidden(true)
                    TextField("Location (e.g. Memphis)", text: $photoSearcher.locationQuery)
                        .multilineTextAlignment(.leading)
                        .focused($locationFocused)
                        .accessibilityHint(Text("Enter a location name to filter photos by where they were taken"))
                        .onSubmit {
                            triggerSearch()
                        }
                        .submitLabel(.search)
                    if !photoSearcher.locationQuery.isEmpty {
                        Button {
                            photoSearcher.locationQuery = ""
                            locationFocused = true
                        } label: {
                            Image(systemName: "delete.left")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                                .accessibilityLabel("Clear location")
                        }
                    }
                }
                .padding(.top, 8)
                if let error = photoSearcher.locationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func triggerSearch() {
        let location = photoSearcher.isLocationFilterActive ? photoSearcher.locationQuery : nil
        print("Searching... query=\(searchText) location=\(location ?? "none")")
        Task {
            await photoSearcher.search(with: searchText, location: location)
        }
    }

    private func clearSearch() {
        self.searchText = ""
        inputFocused = true
        photoSearcher.searchResultCode = .MODEL_PREPARED
    }
}


struct TextFieldClearButton: ViewModifier {
    @ObservedObject var photoSearcher: PhotoSearcher
    var inputFocused: FocusState<Bool>.Binding
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(
                    action: {
                        self.text = ""
                        inputFocused.wrappedValue = true
                        photoSearcher.searchResultCode = .MODEL_PREPARED
                    },
                    label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                )
            }
        }
    }
    
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(photoSearcher: PhotoSearcher())
    }
}
