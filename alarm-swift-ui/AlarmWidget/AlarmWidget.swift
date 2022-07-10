//
//  AlarmWidget.swift
//  AlarmWidget
//
//  Created by Александр on 10.07.2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct AlarmWidgetEntryView : View {
    var entry: Provider.Entry
    @State var isOn: Bool = false

    var body: some View {
        if let alarm = self.getAlarms().filter({ $0.isActive == true }).last {
            VStack {
                Text(alarm.formatted())
                    .font(Font.system(size: 32, weight: .light, design: .default))
                    .widgetURL(URL(string: "widget-deeplink://\(alarm.id)")!)
                Button {
                    
                    print("qwer")
                } label: {
                    Text("Отключить")
                }

            }
            
        } else {
            Text("Нет будильников")
        }
    }
    
    func getAlarms() -> [Alarm] {
        let userDefaults = UserDefaults(suiteName: "group.alarmdatainfo")!

        do {
            if let data = userDefaults.object(forKey: "Alarms") as? Data {
                if let alarms = try PropertyListDecoder().decode([Alarm].self, from: data) as? [Alarm] {
                    return alarms
                }
            }
        } catch (let error) {
            print(error)
        }
        
        return []
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
    
    func offAlarm(id: String) {
        var alarms = getAlarms()
        if let alarm = alarms.first(where: { $0.id == id }) {
            alarm.isActive = false
            alarms.removeAll(where: { id == $0.id })
            alarms.append(alarm)
            save(alarms: alarms)
        }
        
    }
}


class Alarm: Identifiable, Codable, ObservableObject {
    var id = UUID().uuidString
    var date: Int = Int(Date().timeIntervalSince1970)
    var isRepeat: Bool = false
    var title: String = "Будильник"
    var repeatDay: Int = 0
    var isActive: Bool = false
    
    func formatted() -> String {
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "HH:mm"
        
        
        return dFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
    }
}

@main
struct AlarmWidget: Widget {
    let kind: String = "AlarmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AlarmWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct AlarmWidget_Previews: PreviewProvider {
    static var previews: some View {
        AlarmWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
