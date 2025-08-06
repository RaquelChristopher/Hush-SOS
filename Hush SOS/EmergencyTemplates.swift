//
//  EmergencyTemplates.swift
//  Hush SOS
//
//  Created by Jedda Tuuta on 6/8/2025.
//

import Foundation

struct EmergencyTemplate: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let category: EmergencyCategory
    let messageTemplate: String
    
    enum EmergencyCategory: String, CaseIterable {
        case lost = "Navigation"
        case medical = "Medical"
        case weather = "Weather"
        case equipment = "Equipment"
        case wildlife = "Wildlife"
        case general = "General"
    }
}

struct EmergencyMessageBuilder {
    static func createMessage(
        template: EmergencyTemplate,
        userName: String,
        location: String,
        additionalInfo: String = ""
    ) -> String {
        var message = "🚨 DEAF CAMPER EMERGENCY 🚨\n"
        message += "PLEASE CALL 000 IMMEDIATELY\n\n"
        message += "Emergency: \(template.messageTemplate)\n\n"
        message += "I am DEAF and CANNOT make voice calls.\n"
        message += "Please call emergency services for me.\n\n"
        message += "📍 LOCATION:\n\(location)\n\n"
        
        if !userName.isEmpty {
            message += "Name: \(userName)\n"
        }
        
        if !additionalInfo.isEmpty {
            message += "Additional info: \(additionalInfo)\n"
        }
        
        message += "\n⚠️ CRITICAL: Tell 000 this person is DEAF\n"
        message += "🕐 Time: \(Date().formatted(date: .abbreviated, time: .shortened))\n"
        message += "📱 Sent from Emergency Helper App"
        
        return message
    }
}

// Pre-defined templates for Australian camping/hiking
extension EmergencyTemplate {
    static let campingTemplates = [
        EmergencyTemplate(
            title: "Lost on Trail",
            emoji: "🗺️",
            category: .lost,
            messageTemplate: "I AM LOST on hiking trail and need rescue assistance"
        ),
        EmergencyTemplate(
            title: "Medical Emergency",
            emoji: "🩹",
            category: .medical,
            messageTemplate: "MEDICAL EMERGENCY - I am injured and need immediate medical assistance"
        ),
        EmergencyTemplate(
            title: "Severe Weather",
            emoji: "⛈️",
            category: .weather,
            messageTemplate: "Caught in DANGEROUS WEATHER CONDITIONS and need immediate rescue"
        ),
        EmergencyTemplate(
            title: "Equipment Failure",
            emoji: "⚙️",
            category: .equipment,
            messageTemplate: "CRITICAL EQUIPMENT FAILURE - stranded and need rescue assistance"
        ),
        EmergencyTemplate(
            title: "Wildlife Encounter",
            emoji: "🐨",
            category: .wildlife,
            messageTemplate: "DANGEROUS WILDLIFE ENCOUNTER - need immediate assistance"
        ),
        EmergencyTemplate(
            title: "Fall/Injury",
            emoji: "🩼",
            category: .medical,
            messageTemplate: "SERIOUS FALL with potential injuries - cannot move safely"
        ),
        EmergencyTemplate(
            title: "Snake Bite",
            emoji: "🐍",
            category: .medical,
            messageTemplate: "SNAKE BITE EMERGENCY - need immediate medical evacuation"
        ),
        EmergencyTemplate(
            title: "Flash Flood",
            emoji: "🌊",
            category: .weather,
            messageTemplate: "Trapped by FLASH FLOODING - need immediate rescue"
        ),
        EmergencyTemplate(
            title: "Bushfire Threat",
            emoji: "🔥",
            category: .weather,
            messageTemplate: "BUSHFIRE APPROACHING - need immediate evacuation assistance"
        ),
        EmergencyTemplate(
            title: "General Emergency",
            emoji: "🚨",
            category: .general,
            messageTemplate: "EMERGENCY SITUATION - need immediate assistance"
        )
    ]
}
