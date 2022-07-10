//
//  AlarmViewModel.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import Foundation
import UserNotifications

@MainActor class AlarmViewModel: ObservableObject {
    
    @Published public var alarms: [Alarm] = []
    
    init() {
//        self.getAlarms { objects in
//            self.alarms = objects
//        }
    }
    
    func fetchData() {
        self.alarms = NotificationService.shared.getAlarms()
    }
    
    func change(alarmId: String, isActive: Bool) {
        NotificationService.shared.change(alarmId: alarmId, state: isActive)
        NotificationService.shared.fullReload()
    }
    
    func delete(index: IndexSet) {
        for i in index {
            let alarm = self.alarms[i]
            NotificationService.shared.delete(alarmId: alarm.id)
        }
        NotificationService.shared.fullReload()
    }
    
//    func getAlarms(completion: @escaping (([Alarm]) -> Void)) {
//        let alarmsObject = NotificationService.shared.getAlarms()
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            print(requests)
//
//            var alarmObjects: [Alarm] = []
//            var identifiers: [String] = requests.map({ $0.identifier })
//
//            for alarm in alarmsObject {
//                if requests.first(where: { $0.identifier == alarm.id }) != nil {
//                    identifiers.removeAll(where: { $0 == alarm.id })
//                    alarm.isActive = true
//                    alarmObjects.append(alarm)
//                }
//            }
//
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
//
//            completion(alarmObjects)
//        }
//    }
    
}
