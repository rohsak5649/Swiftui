import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var savedTexts: [String] = []
    
    var body: some View {
        VStack {
            TextField("Enter text", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save Text") {
                saveText()
            }
            .padding()
            
            List {
                ForEach(savedTexts, id: \.self) { text in
                    Text(text)
                }
            }
        }
        .onAppear {
            loadSavedTexts()
            scheduleNotifications()
        }
    }
    
    func saveText() {
        savedTexts.append(inputText)
        inputText = ""
        saveToUserDefaults()
    }
    
    func saveToUserDefaults() {
        UserDefaults.standard.set(savedTexts, forKey: "SavedTexts")
    }
    
    func loadSavedTexts() {
        if let texts = UserDefaults.standard.stringArray(forKey: "SavedTexts") {
            savedTexts = texts
        }
    }
    
    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleLocalNotification()
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    func scheduleLocalNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for text in savedTexts {
            let content = UNMutableNotificationContent()
            content.title = "Saved Text Notification"
            content.body = text
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
