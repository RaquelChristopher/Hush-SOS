//
//  ContactManagementView.swift
//  Hush SOS
//
//  Created by Jedda Tuuta on 6/8/2025.
//

import SwiftUI

struct ContactManagementView: View {
    @ObservedObject var contactHelper: ContactHelper
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddContact = false
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if contactHelper.contacts.isEmpty {
                    VStack(spacing: 20) {
                        Text("👥")
                            .font(.system(size: 60))
                        Text("No Emergency Contacts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add people who can call 000 for you in an emergency")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Add First Contact") {
                            showingAddContact = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                } else {
                    List {
                        ForEach(contactHelper.contacts) { contact in
                            ContactRow(contact: contact)
                        }
                        .onDelete(perform: contactHelper.removeContact)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Emergency Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddContact = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView(
                name: $newName,
                phone: $newPhone,
                relationship: $newRelationship
            ) {
                contactHelper.addContact(
                    name: newName,
                    phoneNumber: newPhone,
                    relationship: newRelationship
                )
                newName = ""
                newPhone = ""
                newRelationship = ""
                showingAddContact = false
            }
        }
    }
}

struct ContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(contact.name)
                .font(.headline)
            Text(contact.phoneNumber)
                .font(.subheadline)
                .foregroundColor(.blue)
            Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct AddContactView: View {
    @Binding var name: String
    @Binding var phone: String
    @Binding var relationship: String
    let onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    TextField("Name (e.g., Mum, Dad, Partner)", text: $name)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Relationship (e.g., Parent, Friend)", text: $relationship)
                }
                
                Section("Important") {
                    Text("This person should be able to:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("📞")
                            Text("Call 000 for you")
                        }
                        HStack {
                            Text("🗣️")
                            Text("Speak to emergency services")
                        }
                        HStack {
                            Text("📍")
                            Text("Relay your location information")
                        }
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}
