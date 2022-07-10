//
//  SpeechView.swift
//  alarm-swift-ui
//
//  Created by Александр on 10.07.2022.
//

import SwiftUI
import Speech
import CoreData

struct SpeechView: View {
    @ObservedObject var speechRec = SpeechRec()
    @State var isShowingAlert: Bool = false
    @State var currentDate: Date = Date()
    
    @Environment(\.presentationMode) var presentationMode
    var didReceive: ((Date) -> Void)?
    
    var body: some View {
        VStack {
            Text("Voice Commander. Скажите фразу - поставить будильник на - и время которое вам необходимо")
            Image("microphone-100")
            Text(speechRec.recognizedText)
                .onAppear {
                    self.speechRec.start()
//                    self.speechRec.didReceive = { date in
//                        self.currentDate = date
//                        self.isShowingAlert = true
//                    }
            }
            Button(action: {
                if self.speechRec.isRunning {
                    self.speechRec.stop()
                } else {
                    self.speechRec.start()
                }
            }) {
                Text(self.speechRec.isRunning ? "Stop" : "Start recognition")
                    .font(.body)
                    .padding()
            }
        }
        .onDisappear {
            self.speechRec.stop()
        }
        .alert("Вы дейсвительно хотите поставить будильник на \(self.currentDate.getTime())?", isPresented: $isShowingAlert) {
            Button("Нет", role: .cancel) {
                self.speechRec.start()
            }
            Button("Да", role: .none) {
                self.didReceive?(self.currentDate)
                self.presentationMode.wrappedValue.dismiss()
                print("Done!")
            }
        }
        .onReceive(self.speechRec.$currentDate) { date in
            if let date = date {
                self.currentDate = date
                self.isShowingAlert = true
                print(date)
            }
        }
    }
}

class SpeechRec: ObservableObject {
    
    @Published private(set) var recognizedText = ""
    @Published var currentDate: Date?

    @Published private(set) var isRunning = false
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var didReceive: ((Date) -> Void)?
    
    func start() {
        self.recognizedText = "Начинаем распозновать..."
        SFSpeechRecognizer.requestAuthorization { status in
            self.startRecognition()
        }
    }
    
    func startRecognition() {
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.voiceHander(text: self.recognizedText)
                }
            }
            
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        }
        
        catch {
            
        }
    }
    
    func detectPhrase(text: String) {
        let keyPhrase = "поставить будильник на"
        
        if text.lowercased().contains(keyPhrase) {
            createAlarm()
            self.stop()
        }
    }
    
    func voiceHander(text: String) {
        let keyPhrase = "поставить будильник на"

        let components = text.components(separatedBy: " ")
        if components.count > 3 {
            for i in 0..<components.count {
                let secondIndex = i + 1
                let thirdIndex = i + 2
                let timeIndex = i + 3
                
                if secondIndex >= components.count || thirdIndex >= components.count || timeIndex >= components.count {
                    return
                }
                
                if components[i].lowercased() == "поставить", components[i+1].lowercased() == "будильник", components[i+2].lowercased() == "на" {
                    let time = components[timeIndex]
                    let date = time.isTime()
                    if let date = date {
                        self.stop()
                        self.currentDate = date
                        return
                    }
                }
            }
        }
 
    }
    
    func createAlarm() {
        print("recognize")
    }
    
    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.isRunning = false
    }
    
}

struct SpeechView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechView()
    }
}

extension String {
    
    func isTime() -> Date? {
        let component = self.components(separatedBy: ":")
        guard component.count == 2 else {
            return nil
        }
        
        let hourString = component[0]
        let minuteString = component[1]
        
        guard let hour = Int(hourString), let minute = Int(minuteString) else {
            return nil
        }
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let date = calendar.date(from: dateComponents)
        return date
    }
    
}

extension Date {
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
}
