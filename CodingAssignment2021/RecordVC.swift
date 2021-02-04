//
//  RecordVC.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/1/21.
//

import Anchorage
import SoundAnalysis
import UIKit

/// The view controller for the crying baby detecting screen.
class RecordVC: UIViewController {
    
    var cryIntervals = CryIntervals(confidenceThreshold: Constants.confidenceThreshold, maximumCryGap: Constants.maximumCryGap, minimumCryDuration: Constants.minimumCryDuration)
    let mlDispatchQueue = DispatchQueue(label: Constants.mlDispatchQueueLabel)
    let streamAnalyzer = SNAudioStreamAnalyzer(format: AudioManager.shared.getInputNodeFormat())
    var timer = Timer()
    
    private enum Constants {
        static let buttonTitle = "Start Recording"
        static let cellId = "cell"
        static let confidenceThreshold = 0.5
        static let cryingBabyId = "crying_baby"
        static let dateLabelFont = UIFont(name: "AvenirNext-Medium", size: 32)
        static let navigationTitle = "Record"
        static let maximumCryGap: TimeInterval = 20
        static let minimumCryDuration: TimeInterval = 2
        static let minimumScaleFactor: CGFloat = 0.5
        static let mlDispatchQueueLabel = "MachineLearningDispatchQueue"
        static let mlSetupErrorMessage = "Error: Classifier could not be added."
        static let recordButtonTitle = "Stop Recording"
        static let tableViewCellHeight: CGFloat = 60
        static let timeInterval: TimeInterval = 1
        static let unauthorizedWarningButtonTitle = "OK"
        static let unauthorizedWarningMessage = "Allow microphone access to application in settings."
        static let unauthorizedWarningTitle = "Mic Unauthorized"
    }
    
    private lazy var button: BMButton = {
        let button = BMButton(title: Constants.buttonTitle)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.dateLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.text = FormattedStringManager.getCurrentDate()
        label.textAlignment = .center
        label.textColor = BMColor.babyBlueTextColor
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.clear
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: Constants.cellId)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAttributes()
        addSubviews()
        setupConstraints()
        prepareMLModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc private func processTimer() {
        dateLabel.text = FormattedStringManager.getCurrentDate()
    }
    
    @objc func buttonPressed() {
        guard isAuthorized() else {
            showUnauthorizedWarning()
            return
        }
        if button.isRecordingStyled {
            button.setToNormalStyle(title: Constants.buttonTitle)
            AudioManager.shared.stop()
        }
        else {
            button.setToRecordStyle(title: Constants.recordButtonTitle)
            prepareMLModel()
            AudioManager.shared.start()
        }
    }

    // NOTE: The analyzer reblocks the buffer to the block size expected by the MLModel. By default, analysis occurs on the first audio channel in the audio stream. The analyzer applies sample rate conversion if the provided audio doesn’t match the sample rate required by the MLModel.
    private func prepareMLModel() {
        do {
            AudioManager.shared.installTap { (buffer, audioTime) in
                self.mlDispatchQueue.async {
                    self.streamAnalyzer.analyze(buffer, atAudioFramePosition: audioTime.sampleTime)
                }
            }
            let classifier = try ESC10SoundClassifierModel(configuration: MLModelConfiguration())
            let request = try SNClassifySoundRequest(mlModel: classifier.model)
            try streamAnalyzer.add(request, withObserver: self)
        } catch {
            fatalError(Constants.mlSetupErrorMessage)
        }
    }

    private func showUnauthorizedWarning() {
        let alert = UIAlertController(title: Constants.unauthorizedWarningTitle, message: Constants.unauthorizedWarningMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.unauthorizedWarningButtonTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func isAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

}

// MARK: - UI setup
private extension RecordVC {
    
    func initializeAttributes() {
        tableView.dataSource = self
        timer = Timer.scheduledTimer(timeInterval: Constants.timeInterval, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
        title = Constants.navigationTitle
        view.backgroundColor = BMColor.babyBlueBackgroundColor
    }
    
    func addSubviews() {
        view.addSubview(button)
        view.addSubview(dateLabel)
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        
        // button
        button.centerXAnchor == view.safeAreaLayoutGuide.centerXAnchor
        button.heightAnchor == view.safeAreaLayoutGuide.heightAnchor * 0.1
        button.topAnchor == dateLabel.bottomAnchor + 20
        button.widthAnchor == view.safeAreaLayoutGuide.widthAnchor * 0.5
        
        // dateLabel
        dateLabel.heightAnchor == view.safeAreaLayoutGuide.heightAnchor * 0.1
        dateLabel.leftAnchor == view.safeAreaLayoutGuide.leftAnchor
        dateLabel.rightAnchor == view.safeAreaLayoutGuide.rightAnchor
        dateLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 20
        
        // tableView
        tableView.bottomAnchor == view.bottomAnchor
        tableView.leftAnchor == view.safeAreaLayoutGuide.leftAnchor
        tableView.rightAnchor == view.safeAreaLayoutGuide.rightAnchor
        tableView.topAnchor == button.bottomAnchor + 20
        
    }
    
}

// MARK: - Table view
extension RecordVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryIntervals.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId) as? RecordTableViewCell else { return UITableViewCell() }
        guard let dateInterval = cryIntervals.data[safe: cryIntervals.data.count - indexPath.row - 1] else { return UITableViewCell() }
        cell.configureCell(dateInterval: dateInterval)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewCellHeight
    }
    
}

// MARK: - Sound Analysis
extension RecordVC: SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        guard let cry = (result.classifications.first { $0.identifier == Constants.cryingBabyId }) else { return }
        print("\(cry.identifier): \(cry.confidence)")
        let modificationType = cryIntervals.recordData(confidence: cry.confidence)
        if modificationType == .createdNewEntry {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else if modificationType == .modifiedExistingEntry {
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: .zero, section: .zero)], with: .none)
                self.tableView.endUpdates()
            }
        }
    }
    
}
