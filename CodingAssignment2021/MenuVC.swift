//
//  MenuVC.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 1/31/21.
//

import Anchorage
import UIKit

/// The view controller for the menu screen.
class MenuVC: UIViewController {
    
    private enum Constants {
        static let appImageName = "Baby"
        static let appName = "Baby Monitor"
        static let appNameLabelFont = UIFont(name: "AvenirNext-Medium", size: 45)
        static let backgroundBorderWidth: CGFloat = 3
        static let backgroundCornerRadius: CGFloat = 40
        static let button1Text = "Record"
        static let button2Text = "See History"
        static let minimumScaleFactor: CGFloat = 0.5
        static let stackViewSpacing: CGFloat = 8
    }
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.appNameLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.text = Constants.appName
        label.textAlignment = .center
        label.textColor = BMColor.babyBlueTextColor
        return label
    }()
    
    private lazy var babyIconBackgroudView: UIView = {
        let view = UIView()
        view.backgroundColor = BMColor.babyWhiteBackgroundColor
        view.layer.borderColor = BMColor.babyBlueLineColor.cgColor
        view.layer.borderWidth = Constants.backgroundBorderWidth
        view.layer.cornerRadius = Constants.backgroundCornerRadius
        return view
    }()
    
    private lazy var babyIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Constants.appImageName)
        return imageView
    }()
    
    private lazy var bottomAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var button1: BMButton = {
        let button = BMButton(title: Constants.button1Text)
        button.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        return button
    }()
    
    private lazy var button2: BMButton = {
        let button = BMButton(title: Constants.button2Text)
        button.addTarget(self, action: #selector(seeHistory), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.stackViewSpacing
        return stackView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BMColor.babyBlueBackgroundColor
        addSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

// MARK: - UI setup
private extension MenuVC {
    
    func addSubviews() {
        babyIconBackgroudView.addSubview(babyIconImage)
        bottomAreaView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(button1)
        buttonStackView.addArrangedSubview(button2)
        view.addSubview(appNameLabel)
        view.addSubview(babyIconBackgroudView)
        view.addSubview(bottomAreaView)
    }
    
    func setupConstraints() {
        
        // appNameLabel
        appNameLabel.leftAnchor == view.safeAreaLayoutGuide.leftAnchor + 30
        appNameLabel.rightAnchor == view.safeAreaLayoutGuide.rightAnchor - 30
        appNameLabel.topAnchor == babyIconBackgroudView.bottomAnchor + 20
        
        // babyIconBackgroudView
        babyIconBackgroudView.heightAnchor == view.safeAreaLayoutGuide.heightAnchor * 0.3
        babyIconBackgroudView.leftAnchor == view.safeAreaLayoutGuide.leftAnchor + 30
        babyIconBackgroudView.rightAnchor == view.safeAreaLayoutGuide.rightAnchor - 30
        babyIconBackgroudView.topAnchor == view.safeAreaLayoutGuide.topAnchor + 30
        
        // babyIconImage
        babyIconImage.edgeAnchors == babyIconBackgroudView.edgeAnchors
        
        // bottomAreaView
        bottomAreaView.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor
        bottomAreaView.leftAnchor == view.safeAreaLayoutGuide.leftAnchor
        bottomAreaView.rightAnchor == view.safeAreaLayoutGuide.rightAnchor
        bottomAreaView.topAnchor == appNameLabel.bottomAnchor
        
        // buttonStackView
        buttonStackView.centerAnchors == bottomAreaView.centerAnchors
        buttonStackView.heightAnchor == bottomAreaView.heightAnchor * 0.3
        buttonStackView.widthAnchor == bottomAreaView.widthAnchor * 0.6
        
    }
    
}

// MARK: - Button Selectors
private extension MenuVC {
    
    @objc func startRecording() {
        let destinationVC = RecordVC()
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @objc func seeHistory() {
        print("See History")
    }
    
}
