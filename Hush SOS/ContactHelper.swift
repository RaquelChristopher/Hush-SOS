//
//  ContactHelper.swift
//  Hush SOS
//
//  Created by Jedda Tuuta on 6/8/2025.
//
import Foundation
import SwiftUI

struct EmergencyContact: Identifiable, Codable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
}

class ContactHelper: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    private let saveKey = "EmergencyContacts"
    
    init() {
        loadContacts()
    }
    
    func addContact(name: String, phoneNumber: String, relationship: String) {
        let newContact = EmergencyContact(name: name, phoneNumber: phoneNumber, relationship: relationship)
        contacts.append(newContact)
        saveContacts()
    }
    
    func removeContact(at indexSet: IndexSet) {
        contacts.remove(atOffsets: indexSet)
        saveContacts()
    }
    
    private func saveContacts() {
        if let data = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    private func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let savedContacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) else {
            contacts = []
            return
        }
        contacts = savedContacts
    }
    
    func getPhoneNumbers() -> [String] {
        return contacts.map { $0.phoneNumber }
    }
}
