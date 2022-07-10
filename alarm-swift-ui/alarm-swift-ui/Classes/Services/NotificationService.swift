//
//  NotificationService.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import Foundation
import NotificationCenter

class NotificationService {
    
    static let shared = NotificationService()
    
//    var alarms: [Alarm] {
//        get {
//            do {
//                if let data = UserDefaults.standard.object(forKey: "Alarms") as? Data {
//                    if let alarms = try PropertyListDecoder().decode([Alarm].self, from: data) as? [Alarm] {
//                        return alarms
//                    }
//                }
//            } catch (let error) {
//
//            }
//
//            return []
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "Alarms")
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    public func initialize() {
     
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func fullReload() {
        var objects = getAlarms()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for object in objects {
            if object.isActive {
                NotificationService.addRequest(alarm: object) { status in
                    //
                }
            }
        }
    }
    
    public func getAlarms() -> [Alarm] {
        let userDefaults = UserDefaults(suiteName: "group.alarmdatainfo")!

        do {
            if let data = userDefaults.object(forKey: "Alarms") as? Data {
                if let alarms = try PropertyListDecoder().decode([Alarm].self, from: data) as? [Alarm] {
                    return alarms
                }
            }
        } catch (let error) {
            
        }
        
        return []
    }
    
    func change(alarmId: String, state: Bool) {
        var objects = self.getAlarms()
        
        if let alarm = objects.first(where: { $0.id == alarmId }) {
            let newAlarm = alarm
            newAlarm.isActive = state
            objects.removeAll(where: { $0.id == alarmId })
            objects.append(newAlarm)
            save(alarms: objects)
        }
    }
    
    func delete(alarmId: String) {
        var objects = self.getAlarms()
        objects.removeAll(where: { $0.id == alarmId })
        save(alarms: objects)
    }
    
    func add(alarm: Alarm) {
        var objects = self.getAlarms()
        objects.append(alarm)
        
        do
        {
            let userDefaults = UserDefaults(suiteName: "group.alarmdatainfo")!
            userDefaults.set(try PropertyListEncoder().encode(objects), forKey: "Alarms")
            userDefaults.synchronize()
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    private func save(alarms: [Alarm]) {
        do
        {
            let userDefaults = UserDefaults(suiteName: "group.alarmdatainfo")!
            userDefaults.set(try PropertyListEncoder().encode(alarms), forKey: "Alarms")
            userDefaults.synchronize()
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    static func addRequest(alarm: Alarm, completion: @escaping ((Bool) -> Void)) {
        
        let current = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.categoryIdentifier = alarm.id
        content.sound = UNNotificationSound(named: UNNotificationSoundName("IGotYouBabe.aiff"))
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(alarm.date)))
        let minute = calendar.component(.minute, from: Date(timeIntervalSince1970: TimeInterval(alarm.date)))
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
        
        current.add(request) { error in
            if (error == nil) {
                completion(true)
                print("successfully")
            } else {
                completion(false)
                print("error")
            }
        }
    }
    
}
