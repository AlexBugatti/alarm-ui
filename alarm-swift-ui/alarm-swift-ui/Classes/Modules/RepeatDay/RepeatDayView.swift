//
//  RepeatDayView.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import SwiftUI

struct Repeat: Identifiable, Hashable {
    var title: String
    var id: Int
}

struct RepeatDayView: View {
    
    @State var repeatDay: Int
    var didSelect: ((Repeat) -> Void)?
//    @State private var selectedRow: Int = 0
    
    var repeats: [Repeat] = [Repeat(title: "Каждый день", id: 0),
                             Repeat(title: "Каждый понедельник", id: 1),
                             Repeat(title: "Каждый вторник", id: 2),
                             Repeat(title: "Каждая среда", id: 3),
                             Repeat(title: "Каждый четверг", id: 4),
                             Repeat(title: "Каждая пятница", id: 5),
                             Repeat(title: "Каждая суббота", id: 6),
                             Repeat(title: "Каждое воскресение", id: 7)]
    
    var body: some View {
        let withIndex = repeats.enumerated().map({ $0 })
        List(withIndex, id: \.element) { index, rep in
            Button {
                print(rep.title)
                self.repeatDay = index
                self.didSelect?(self.repeats[index])
            } label: {
                HStack {
                    Text(rep.title)
                    Spacer()
                    Image(image(row: index))
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
//            WeekdayCell(weekday: rep, index: index)
        }
    }
    
    func image(row: Int) -> String {
        return self.repeatDay == row ? "check" : ""
    }
}

//struct WeekdayCell: View {
//
//    let weekday: Repeat
//    var index: Int
//    @State var isActive: Bool = false
//
//    var body: some View {
//        Button {
//            print(weekday.title)
//        } label: {
//            HStack {
//                Text(weekday.title)
//                Spacer()
//            }
//        }
//
//    }
//}

struct RepeatDayView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatDayView.init(repeatDay: 0)
    }
}
