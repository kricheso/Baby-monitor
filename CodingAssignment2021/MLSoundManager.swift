//
//  MLSoundManager.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/4/21.
//

import SoundAnalysis

struct MLSoundManager {
    
    static let audioEngine = AVAudioEngine()
    
    // NOTE: The analyzer reblocks the buffer to the block size expected by the MLModel. By default, analysis occurs on the first audio channel in the audio stream. The analyzer applies sample rate conversion if the provided audio doesn’t match the sample rate required by the MLModel.
    static func addRequest(to streamAnalyzer: SNAudioStreamAnalyzer, for observer: SNResultsObserving) {
        do {
            let soundClassifier = try ESC10SoundClassifierModel(configuration: MLModelConfiguration())
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try streamAnalyzer.add(request, withObserver: observer)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getInputNodeFormat() -> AVAudioFormat {
        return audioEngine.inputNode.outputFormat(forBus: 0)
    }
    
    static func installTap(tapBlock: @escaping AVAudioNodeTapBlock) {
        removeTap()
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 15600,
            format: audioEngine.inputNode.outputFormat(forBus: 0),
            block: tapBlock
        )
    }
    
    static func removeTap() {
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    static func start() {
        audioEngine.prepare()
        do { try audioEngine.start() }
        catch { print(error.localizedDescription) }
    }
    
    static func stop() {
        audioEngine.stop()
    }

}
