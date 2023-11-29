//
//  nfcWriterButton.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 13.10.23.
//

import SwiftUI
import CoreNFC

struct nfcWriterButton: View {
   
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentTheme: Theme {
        return self.themeManager.currentTheme()
    }
    
    @State private var nfcReader = NFCReader()
    @State private var protheseAlert = false
    @State private var stopWatchToggleAlert = false
    @State private var deepLinkstopWatchToggle = "ProProthese://stopWatchToggle"

    @FetchRequest private  var allProthesis: FetchedResults<Prothese>
    
    init() {
        _allProthesis = FetchRequest<Prothese>(
            sortDescriptors: []
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    stopWatchToggleAlert.toggle()
                }) {
                    HStack {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("NFC-Tag for \"StopWatchToggle\" describe")
                        Spacer()
                    }
                }
                .padding(15)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .alert("StopWatchToggle", isPresented: $stopWatchToggleAlert) {
                        TextField("NFC tag name", text: $deepLinkstopWatchToggle)
                           .textInputAutocapitalization(.never)
                        Button("OK", action: {
                            if !deepLinkstopWatchToggle.isEmpty || deepLinkstopWatchToggle != "" {
                                nfcReader.scanNFCTag(string: deepLinkstopWatchToggle)
                            }
                        })
                       Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Please enter an DeepLink.")
                }
                
                Spacer()
            }
            
            HStack {
                Button(action: {
                    protheseAlert.toggle()
                }) {
                    HStack {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        
                        Text("NFC tag describe prostheses")
                        Spacer()
                    }
                }
                .padding(15)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .alert("NFC tag describe prostheses", isPresented: $protheseAlert) {
                    
                    ForEach(combinedProthesisStrings) {
                        if let (t,k) = parseProthesisString($0) {
                            let str = "\(formatProthesisStringAddUnderline(t))&\(formatProthesisStringAddUnderline(k))"
                            Button("ProProthese://\(str)") {  nfcReader.scanNFCTag(string: "ProProthese://\(str)") }
                                
                        }
                    }
                    
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Choose a prosthesis.")
                }
                
                Spacer()
            }
            
            InfomationField(
                 backgroundStyle: .ultraThin,
                 text: "In order to use the NFC functionality for timer control, you must first register your prostheses and liners in the app. By entering your prostheses under \"Prostheses and Liners\", you allow the app to configure individual timers for each type of prosthesis.",
                 visibility: true
            )
        }
        .foregroundColor(currentTheme.text)
        .padding(.horizontal)
    }
    
    var combinedProthesisStrings: [String] {
        var combinedProthesisStrings: [String] = []

        prothesis.allTypesForButton.forEach { proType in
            prothesis.allKindsForButton.forEach { proKind in
                if proType != "" {
                    
                    if AppConfig.shared.NFCallowMyprotheses { // FOR SETTINGS
                        let _ = allProthesis.map({ prothese in
     
                            guard let type = prothese.type, let kind = prothese.kind else { return }
                            
                            guard type == proType && proKind.contains(kind) else { return }
                            
                            combinedProthesisStrings.append("\( proType )&\(proKind)")
                        })
                    } else {
                        combinedProthesisStrings.append("\( proType )&\(proKind)")
                    }
                    
                }
            }
        }
        
        return combinedProthesisStrings
    }
    
    func formatProthesisStringAddUnderline(_ inputString: String) -> String {
        // Ersetze Leerzeichen durch Unterstriche
        let formattedString = inputString.replacingOccurrences(of: " ", with: "_")
        return formattedString
    }
    
    func parseProthesisString(_ prothesisString: String) -> (type: String, kind: String)? {
           // Trenne den String bei "&"
           let components = prothesisString.components(separatedBy: "&")
           
           // Überprüfe, ob die Komponenten vorhanden und in der erwarteten Anzahl sind
           guard components.count == 2 else {
               return nil
           }
           
           // Extrahiere die Teile und gib ein Tupel zurück
           let type = components[0]
           let kind = components[1]
           
           return (kind: kind, type: type)
       }
}

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    
    var currentData: String = ""
    var NFCSession: NFCReaderSession?
    
    func scanNFCTag(string: String) {
        currentData = string
        NFCSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        NFCSession?.alertMessage = "Hold your iPhone Near an NFC Card"
        NFCSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(session, error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {

    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let string = currentData
        
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More as one Tag ditected, pleace try again!"
            
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
        }

        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to your NFC TAG!"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                
                guard error == nil else {
                    session.alertMessage = "Unable to connect to your NFC TAG!"
                    session.invalidate()
                    return
                }
                
                switch status {
                case .notSupported:
                    session.alertMessage = "Unable to connect to your NFC TAG!"
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Unable to connect to your NFC TAG!"
                    session.invalidate()
                case .readWrite:
                    
                    tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: string)!]), completionHandler: {(error: Error?) in
                    
                        if error != nil {
                            session.alertMessage = "Write NFC TAG Message Failed."
                        } else {
                            session.alertMessage = "Write NFC TAG success!\n**URL**: \(string)"
                        }
                        session.invalidate()
                        
                    })
                @unknown default:
                    session.alertMessage = "Unknown Error"
                    session.invalidate()
                    
                }
                
            })
            
        })
        
    }
}



