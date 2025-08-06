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
    @State private var emergencyMessage = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // App Title
                Text("🚨 Emergency Helper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
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
                }
                
                // Big SOS Button
                Button(action: {
                    handleSOSPressed()
                }) {
                    Text("🚨 SEND SOS")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 100)
                        .background(canSendSOS ? Color.red : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(radius: 5)
                }
                .disabled(!canSendSOS)
                
                Spacer()
                
                // Settings Section
                VStack(spacing: 15) {
                    Button("👥 Manage Contacts") {
                        showingContactSheet = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    TextField("Your name (optional)", text: $userName)
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
        .alert("Emergency Test", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    var canSendSOS: Bool {
        return !contactHelper.contacts.isEmpty
    }
    
    func handleSOSPressed() {
        showEmergencyOptions()
    }
    
    func showEmergencyOptions() {
        alertMessage = "🚨 Emergency feature activated!\n\nIn a real emergency, this would:\n• Get your GPS location\n• Send SMS to your contacts\n• Include emergency details"
        showingAlert = true
    }
}

// Helper Views
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
