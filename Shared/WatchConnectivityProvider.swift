import Combine
import WatchConnectivity
import UserNotifications


class StateManager: ObservableObject {
    
    static let sharedManager = StateManager()
    
    var session: WCSession = .default
    
    let delegate: WCSessionDelegate
    
    let subject = CurrentValueSubject<Bool, Never>(false)
    let dateSubject = CurrentValueSubject<Date?, Never>(nil)
    
    @Published private(set) var state: Bool = false
    @Published private(set) var date: Date? = nil
    @Published var paired = false
    
    private var debug = false
    
    init(session: WCSession = .default) {
        self.session = session
        
        self.delegate = SessionDelegater(boolSubject: subject, dateSubject: dateSubject)
        
        self.connect()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        
        self.session.delegate = self.delegate
        session.activate()
    }

    #if os(iOS)
    func isPaired(complication: @escaping(Bool) -> ()) {
        guard session.isPaired else {
            print("Watch is not Avaible")
            return complication(false)
        }
        
        complication(true)
    }
    #endif
    
    func updateApplicationContext(with context: [String : Any] ) {
        do {
            try self.session.updateApplicationContext(context)
        } catch {
            print("Updating of application context failed \(error)")
        }
    }

}


class SessionDelegater: NSObject, WCSessionDelegate {
    let boolSubject: CurrentValueSubject<Bool, Never>
    
    let dateSubject: CurrentValueSubject<Date?, Never>
    
    init(boolSubject: CurrentValueSubject<Bool, Never>, dateSubject: CurrentValueSubject<Date?, Never>) {
        self.boolSubject = boolSubject
        self.dateSubject = dateSubject
        super.init()
    }
        
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Protocol comformance only
        // Not needed for this demo
        if activationState == .activated {
            //  print("Watch Connected")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {

    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
           if let state = message["state"] as? Bool {
               self.boolSubject.send((state != false))
           } else {
               print("There was an error")
           }
            
            if let date = message["Date"] as? Date? {
                self.dateSubject.send(date ?? nil)
            } else {
                print("There was an error")
            }
       }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: ([String: Any]) ) {
        // Receive application context sent from counterpart
        // session.receivedApplicationContext is updated automatically
        print("applicationContext: \(applicationContext)")
        
        if let d = applicationContext["date"] as? Date {
            print("Update date \(d))")
           self.dateSubject.send(d)
        } else {
           print("There was an error")
        }
        
        if let s = applicationContext["state"] as? Bool {
            print("Update state \(s))")
           self.boolSubject.send(s)
        } else {
           print("There was an error")
        }
    }
    
    #if os(iOS)
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isPaired {
            print("Watch is Avaible")
            StateManager.sharedManager.paired = true
        } else{
            print("Watch is not Avaible")
            StateManager.sharedManager.paired = false
        }
    }
    #endif
    
    internal func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        debugPrint("didReceiveMessage: \(applicationContext)")
        
        DispatchQueue.main.async {
            
            if let int = applicationContext["state"] as? Int {
                if int == 1 { // error is true
                    print("error is true")
                    self.boolSubject.send(true)
                    
                }
                if int == 0 { // error does not exist/ false.
                    print("error is false")
                    self.boolSubject.send(false)
                }
            } else {
                print("There was an error in 'state'")
            }
            
            if let date = applicationContext["Date"] as? Date? {
                self.dateSubject.send(date ?? nil)
            } else {
                print("There was an error 'date'")
            }
       }
    }
    
    
    
    // iOS Protocol comformance
    // Not needed for this demo otherwise
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
}

enum ProthesisTimer {
    
    var id: Self { self }
    
    case isRunning
    case notRunning
    
    
}
enum Device {
    case iphone, watch, none
}

extension Bool
{
    init(_ intValue: Int)
    {
        switch intValue
        {
        case 0:
            self.init(false)
        default:
            self.init(true)
        }
    }
}
