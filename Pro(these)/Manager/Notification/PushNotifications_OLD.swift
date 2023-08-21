//
//  PushNotifications.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 25.04.23.
//


import SwiftUI


// https://emojiterra.com/de/nachdenkender-smiley/
class PushNotifications {
    

    var en:[(id: String, message: Message)] = [
            (id: "ComeBack1", message: Message(
                identifier: "PROTHESE_COMEBACK_REMINDER_1",
                titel: LocalizedStringKey("We haven't seen you today 😢"),
                body: LocalizedStringKey("Come back soon, it will be exciting ✌️"),
                triggerTimer: 20,
                url: URL(string: "ProProthese://statistic")!
            )), (id: "ComeBack2", message: Message(
                identifier: "PROTHESE_COMEBACK_REMINDER_2",
                titel: LocalizedStringKey("How are you doing? 🤔"),
                body: LocalizedStringKey("It's so quiet here without you...😢"),
                triggerTimer: 20,
                url: URL(string: "ProProthese://statistic")!
            )), (id: "GoodMorning", message: Message(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_1",
                titel: LocalizedStringKey("Start the day well 🦾 🦾"),
                body: LocalizedStringKey("Think of your prosthesis diary and behave in your time. ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")!
            )), (id: "GoodMorning", message: Message(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_2",
                titel: LocalizedStringKey("Good morning motivation 🦾 🦾"),
                body: LocalizedStringKey("Happiness is not a goal. Happiness is a way of life. Be happy today and share it with us... ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")!
            )), (id: "GoodMorning", message: Message(
                identifier: "PROTHESE_MOOD_GOOD_MORNING_3", //
                titel: LocalizedStringKey("have a good morning 😃"),
                body: LocalizedStringKey("Don't go where the path may lead you, go where there is no path and write down your notes. ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationGoodMorningDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationGoodMorningDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")! // Du hast gestern garnicht vorbeigeschaut. Möchtest du nicht aktiv werden und deine Protheseneindrücke mit mir teilen?
            )), (id: "MoodReminderDaily1", message: Message(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_1",
                titel: LocalizedStringKey("Pro Prothese"),
                body: LocalizedStringKey("Hey! How are you feeling today? ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")!
            )), (id: "MoodReminderDaily2", message: Message(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_2",
                titel: LocalizedStringKey("Pro Prothese"),
                body: LocalizedStringKey("Hey! A new day, new experiences, don't you want to save them? ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")!
            )), (id: "MoodReminder", message: Message(
                identifier: "PROTHESE_MOOD_REMINDER_DAILY_3",
                titel: LocalizedStringKey("Tell me about your day 🦾 🦾"),
                body: LocalizedStringKey("Don't leave a blank page in your prosthesis diary. ✌️"),
                triggerHour: Calendar.current.component(.hour, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                triggerMinute: Calendar.current.component(.minute, from: AppConfig.shared.PushNotificationDailyMoodRememberingDate),
                repeater: true,
                url: URL(string: "ProProthese://addFeeling")!
            ))
    ]
    /*
    var ComeBack1:Message = Message(
        identifier: "PROTHESE_COMEBACK_REMINDER1",
        titel: LocalizedStringKey("We haven't seen you today 😢"),
        body: LocalizedStringKey("Come back soon, it will be exciting ✌️"),
        triggerTimer: 20,
        url: URL(string: "ProProthese://statistic")!
    )
    
    var TEST:Message = Message(
        identifier: "PROTHESE_COMEBACK_TEST",
        titel: LocalizedStringKey("We haven't seen you today 😢"),
        body: LocalizedStringKey("Come back soon, it will be exciting ✌️"),
        triggerTimer: 20,
        url: URL(string: "ProProthese://statistic")!
    )
    
    var ComeBack2:Message = Message(
        identifier: "PROTHESE_COMEBACK_REMINDER2",
        titel: LocalizedStringKey("How are you doing? 🤔"),
        body: LocalizedStringKey("It's so quiet here without you...😢"),
        triggerTimer: 20,
        url: URL(string: "ProProthese://statistic")!
    )
    
    var MoodReminder:Message = Message(
        identifier: "PROTHESE_MOOD_REMINDER",
        titel: LocalizedStringKey("Tell me about your day 🦾 🦾"),
        body: LocalizedStringKey("Don't leave a blank page in your prosthesis diary. ✌️"),
        triggerHour: 20,
        triggerMinute: 30,
        repeater: true,
        url: URL(string: "ProProthese://addFeeling")!
    )
    
    var GoodMorning:Message = Message(
        identifier: "PROTHESE_MOOD_GOOD_MORNING",
        titel: LocalizedStringKey("Start the day well 🦾 🦾"),
        body: LocalizedStringKey("Think of your prosthesis diary and behave in your time. ✌️"),
        triggerHour: 7,
        triggerMinute: 30,
        repeater: true,
        url: URL(string: "ProProthese://addFeeling")!
    )
    
    var MoodReminderDaily1:Message = Message(
        identifier: "PROTHESE_MOOD_REMINDER_DAILY_1",
        titel: LocalizedStringKey("Pro Prothese"),
        body: LocalizedStringKey("Hey! How are you feeling today? ✌️"),
        triggerHour: 7,
        triggerMinute: 30,
        repeater: true,
        url: URL(string: "ProProthese://addFeeling")!
    )
    
    var MoodReminderDaily2:Message = Message(
        identifier: "PROTHESE_MOOD_REMINDER_DAILY_2",
        titel: LocalizedStringKey("Pro Prothese"),
        body: LocalizedStringKey("Hey! A new day, new experiences, don't you want to save them? ✌️"),
        triggerHour: 7,
        triggerMinute: 30,
        repeater: true,
        url: URL(string: "ProProthese://addFeeling")!
    )
    */
}

struct Message {
    var identifier: String
    var titel: LocalizedStringKey
    var body: LocalizedStringKey
    var triggerHour: Int?
    var triggerMinute: Int?
    var triggerTimer: Int?
    var repeater: Bool?
    var url: URL
    
}
