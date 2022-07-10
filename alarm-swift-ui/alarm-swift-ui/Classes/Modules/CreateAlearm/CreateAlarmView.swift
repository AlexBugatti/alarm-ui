//
//  CreateAlarmView.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import SwiftUI
import UserNotifications

class Alarm: Identifiable, Codable, ObservableObject {
    var id = UUID().uuidString
    var date: Int = Int(Date().timeIntervalSince1970)
    var isRepeat: Bool = false
    var title: String = "Будильник"
    var repeatDay: Int = 0
    var isActive: Bool = true
    
    func formatted() -> String {
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        
        
        return dFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
    }
}

struct CreateAlarmView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var alarm = Alarm()
    @State var date: Date
    @State private var isPresented = false
    @State private var isShowAlert = false
    
    var didDismiss: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("",
                           selection: $date,
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                HStack {
                    Text("Повтор")
                    Spacer()
                    NavigationLink(destination: RepeatDayView(repeatDay: alarm.repeatDay, didSelect: didSelectDay(repeatDay:)), isActive: $isPresented) {
                        Text("Никогда")
                    }
                }
                .padding(16)
                HStack {
                    Text("Название")
                    Spacer()
                    Button("Будильник") {
                        print(alarm.date)
                    }
                }
                .padding(16)
                Spacer()
            }
                .navigationTitle("Новый будильник")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            self.didDismiss?()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Создать") {
                            self.create()
                        }
                    }
                }
        }
        .onAppear {
            print("uud \(alarm.id)")
        }
        .alert("Разрешите доступ к нотификациям в настройках", isPresented: $isShowAlert, actions: {
            //
        })
    }
    
    func didSelectDay(repeatDay: Repeat) {
        self.alarm.repeatDay = repeatDay.id
    }
    
    func create() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.alarm.date = Int(date.timeIntervalSince1970)
                NotificationService.shared.add(alarm: self.alarm)

                self.didDismiss?()
                self.presentationMode.wrappedValue.dismiss()

            } else if let error = error {
                self.isShowAlert = true
                print(error.localizedDescription)
            }
        }
    }
    
}

//struct PickerView: View {
//
//    @State var alarm: Alarm
//    @State private var isPresented = false
//
//    var body: some View {
//
//    }
//}

struct CreateAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAlarmView(date: Date())
    }
}
