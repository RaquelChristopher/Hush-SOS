import SwiftUI
import CoreLocation
import MessageUI

struct ContentView: View {
    @StateObject private var locationHelper = LocationHelper()
    @StateObject private var contactHelper = ContactHelper()
    
    @State private var showingContactSheet = false
    @State private var showingEmergencyOptions = false
    @State private var showingMessageComposer = false
    @State private var userName = ""
    @State private var selectedTemplate: EmergencyTemplate?
    @State private var emergencyMessage = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                // App Title
                Text("🚨 Emergency Helper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("For Deaf Campers & Hikers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Status Section
                VStack(spacing: 15) {
                    StatusCard(
                        title: "Location Status",
                        content: locationHelper.locationText,
                        isGood: locationHelper.hasPermission && locationHelper.currentLocation != nil
                    )
                    
                    StatusCard(
                        title: "Emergency Contacts",
                        content: "\(contactHelper.contacts.count) contacts saved",
                        isGood: !contactHelper.contacts.isEmpty
                    )
                    
                    StatusCard(
                        title: "SMS Capability",
                        content: MFMessageComposeViewController.canSendText() ? "Ready to send messages" : "SMS not available",
                        isGood: MFMessageComposeViewController.canSendText()
                    )
                }
                
                // Big Emergency Button
                Button(action: {
                    handleEmergencyPressed()
                }) {
                    VStack {
                        Text("🚨")
                            .font(.system(size: 40))
                        Text("EMERGENCY")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("SEND SOS")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 280, height: 120)
                    .background(canSendSOS ? Color.red : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .scaleEffect(canSendSOS ? 1.0 : 0.95)
                }
                .disabled(!canSendSOS)
                .animation(.easeInOut(duration: 0.2), value: canSendSOS)
                
                if !canSendSOS {
                    Text("⚠️ Setup needed: Add contacts & enable location")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Settings Section
                VStack(spacing: 15) {
                    Button("👥 Manage Emergency Contacts") {
                        showingContactSheet = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    TextField("Your name (for emergency services)", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Emergency Helper")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingContactSheet) {
            ContactManagementView(contactHelper: contactHelper)
        }
        .actionSheet(isPresented: $showingEmergencyOptions) {
            createEmergencyActionSheet()
        }
        .sheet(isPresented: $showingMessageComposer) {
            if MFMessageComposeViewController.canSendText() {
                MessageComposeView(
                    message: emergencyMessage,
                    recipients: contactHelper.getPhoneNumbers()
                ) { result in
                    handleMessageResult(result)
                }
            }
        }
        .alert("Emergency Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            locationHelper.getCurrentLocation()
            loadUserName()
        }
        .onChange(of: userName) { _ in
            saveUserName()
        }
    }
    
    var canSendSOS: Bool {
        return !contactHelper.contacts.isEmpty &&
               MFMessageComposeViewController.canSendText() &&
               locationHelper.hasPermission
    }
    
    func handleEmergencyPressed() {
        locationHelper.getCurrentLocation()
        showingEmergencyOptions = true
    }
    
    func createEmergencyActionSheet() -> ActionSheet {
        var buttons: [ActionSheet.Button] = []
        
        // Add template buttons
        for template in EmergencyTemplate.campingTemplates {
            buttons.append(.destructive(Text("\(template.emoji) \(template.title)")) {
                sendEmergencyMessage(template: template)
            })
        }
        
        // Add cancel button
        buttons.append(.cancel())
        
        return ActionSheet(
            title: Text("🚨 SELECT EMERGENCY TYPE"),
            message: Text("This will send SMS to all your emergency contacts"),
            buttons: buttons
        )
    }
    
    func sendEmergencyMessage(template: EmergencyTemplate) {
        let locationText = locationHelper.getEmergencyLocationText()
        
        emergencyMessage = EmergencyMessageBuilder.createMessage(
            template: template,
            userName: userName,
            location: locationText
        )
        
        showingMessageComposer = true
    }
    
    func handleMessageResult(_ result: MessageComposeResult) {
        switch result {
        case .sent:
            alertMessage = "✅ Emergency SOS sent successfully!\n\nYour emergency contacts have been notified and should call 000 for you."
        case .failed:
            alertMessage = "❌ Failed to send emergency message.\n\nTry again or call 000 directly if possible."
        case .cancelled:
            alertMessage = "Emergency message cancelled."
        @unknown default:
            alertMessage = "Unknown result from message sending."
        }
        showingAlert = true
    }
    
    func saveUserName() {
        UserDefaults.standard.set(userName, forKey: "UserName")
    }
    
    func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "UserName") ?? ""
    }
}

// Helper Views (StatusCard and SecondaryButtonStyle remain the same)
struct StatusCard: View {
    let title: String
    let content: String
    let isGood: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(isGood ? "✅" : "⚠️")
            }
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}
