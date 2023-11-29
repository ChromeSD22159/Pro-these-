//
//  AppVersion.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 17.10.23.
//

import SwiftUI

struct AppVersionView: View {
    
    @State var appVerion: AppVersion? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Version History")
            
            
            ForEach(appVerion?.data ?? [], id: \.id) { version in
                let attributes = version.attributes
                AppVersionDisclosureGroup {
                    VStack {
                        Text(attributes.content)
                    }
                } header: {
                   HStack {
                       Text("Version-Nummer \(attributes.build)")
                       Spacer()
                       Text(attributes.createdAt)
                   }
               }
            }
            
            
        }
        .onAppear {
            loadAppVersions { result in
                switch result {
                case .success(let appVersion):
                    print("App-Versionen geladen: \(appVersion)")
                    // Handle the loaded app versions here
                case .failure(let error):
                    print("Fehler beim Laden der App-Versionen: \(error)")
                    // Handle the error here
                }
            }
        }
    }
    
    func loadAppVersions(completion: @escaping (Result<AppVersion, Error>) -> Void) {
        // URL für die API-Abfrage
        guard let url = URL(string: "http://localhost:1337/api/versions/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // URLSession-Task zum Laden der Daten
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "Failed to retrieve data", code: 0, userInfo: nil)))
                return
            }

            do {
                // Daten dekodieren
                let decoder = JSONDecoder()
                let appVersion = try decoder.decode(AppVersion.self, from: data)
                completion(.success(appVersion))
            } catch {
                completion(.failure(error))
            }
        }

        // Task starten
        task.resume()
    }
}

struct AppVersionDisclosureGroup<Header: View, Content: View>: View {
    @State private var isExpanded: Bool = false

    var content: () -> Content
    var header: () -> Header

    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) {
        self.content = content
        self.header = header
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                Text("Content Bereich")
                    .padding()
            },
            label: {
                HStack {
                    Text("Datum und Build-Nummer")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.blue)
                    Spacer()
                }
                .background(Color.gray.opacity(0.1))
            }
        )
        .padding()
    }
}

