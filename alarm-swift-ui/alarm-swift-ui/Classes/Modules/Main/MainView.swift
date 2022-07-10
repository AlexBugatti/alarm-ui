//
//  MainView.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import SwiftUI
import WidgetKit
import Speech

extension NSNotification {
    static let fireDate = Notification.Name.init("FireDate")
    static let updateAlarms = Notification.Name.init("UpdateAlarms")
}

struct MainView: View {
    @State private var isPresented = false
    @State private var isPresentedOffScreen = false
    @State private var isPresentedSpeechScreen = false
    @State private var isSpeechDate = false
    @State private var speechDate: Date = Date()
    
    @StateObject var alarmViewModel = AlarmViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(alarmViewModel.alarms) { alarm in
                    AlarmCell(alarm: alarm) { alarmId, isActive in
                        self.alarmViewModel.change(alarmId: alarmId, isActive: isActive)
                        self.alarmViewModel.fetchData()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }.onDelete(perform: delete)
            }
//            List(alarmViewModel.alarms) { alarm in
//                AlarmCell(alarm: alarm) { alarmId, isActive in
//                    self.alarmViewModel.change(alarmId: alarmId, isActive: isActive)
//                    self.alarmViewModel.fetchData()
//                }
//            }
            .task {
                self.alarmViewModel.fetchData()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        self.isPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    Spacer()
                    Button {
                        self.isPresentedSpeechScreen.toggle()
                    } label: {
                        Image("microphone", bundle: nil)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .popover(isPresented: $isPresented, content: {
                        CreateAlarmView(date: Date(), didDismiss: didCreateDismissed)
                    })
                    .popover(isPresented: $isPresentedSpeechScreen, content: {
                        SpeechView(didReceive: didReceiveDate(date:))
                    })
                }
            }
            .navigationTitle("Будильники")
        }
        .onAppear {
            NotificationService.shared.initialize()
            NotificationService.shared.fullReload()
            self.alarmViewModel.fetchData()
        }
        .fullScreenCover(isPresented: $isPresentedOffScreen, content: {
            OffView()
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.fireDate)) { output in
            self.isPresentedOffScreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.updateAlarms)) { output in
            self.alarmViewModel.fetchData()
        }
        .popover(isPresented: $isSpeechDate, content: {
            CreateAlarmView(date: self.speechDate, didDismiss: didCreateDismissed)
        })
    }
    
    func delete(at offsets: IndexSet) {
        self.alarmViewModel.delete(index: offsets)
        self.alarmViewModel.fetchData()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func didCreateDismissed() {
        NotificationService.shared.fullReload()
        self.alarmViewModel.fetchData()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func didReceiveDate(date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.speechDate = date
            self.isSpeechDate = true
        }
    }

}

struct AlarmCell: View {
    let alarm: Alarm
    var didChange: ((String, Bool) -> Void)?
    
    @State var isActive: Bool = false
    
    var body: some View {
        HStack {
            VStack {
                Text(alarm.formatted())
                    .font(Font.system(size: 32, weight: .light, design: .default))
                Text(alarm.title)
                    .font(Font.system(size: 12, weight: .regular, design: .default))
            }
            Spacer()
            Toggle("", isOn: $isActive)
                .onChange(of: isActive) { newValue in
                    self.didChange?(alarm.id, newValue)
                    print(isActive)
                }
        }
        .onAppear {
            self.isActive = alarm.isActive
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDevice("iPhone 11")
    }
}
