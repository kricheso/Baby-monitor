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
    
    private var cryIntervals = CryIntervals(confidenceThreshold: Constants.confidenceThreshold, maximumCryGap: Constants.maximumCryGap, minimumCryDuration: Constants.minimumCryDuration)
    private var timer = Timer()
    private let mlDispatchQueue = DispatchQueue(label: Constants.mlDispatchQueueLabel)
    private var streamAnalyzer = SNAudioStreamAnalyzer(format: MLSoundManager.getInputNodeFormat())
    
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
        configureMLSoundAnalyzer()
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
            MLSoundManager.stop()
        }
        else {
            button.setToRecordStyle(title: Constants.recordButtonTitle)
            MLSoundManager.start()
        }
    }
    
    private func configureMLSoundAnalyzer() {
        MLSoundManager.installTap { [weak self] (buffer, when) in
            guard let self = self else { return }
            self.mlDispatchQueue.async {
                self.streamAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
            }
        }
        MLSoundManager.addRequest(to: streamAnalyzer, for: self)
    }

    private func showUnauthorizedWarning() {
        let alert = UIAlertController(title: Constants.unauthorizedWarningTitle, message: Constants.unauthorizedWarningMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.unauthorizedWarningButtonTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    /// Determines if the user allowed microphone access. iOS Simulators are automatically authorized.
    private func isAuthorized() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        #endif
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
