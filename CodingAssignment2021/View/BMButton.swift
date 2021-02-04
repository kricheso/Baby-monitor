//
//  BMButton.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/1/21.
//

import UIKit

/// Standard button used in the Baby Monitor App.
class BMButton: UIButton {
    
    private(set) var isRecordingStyled = false
    
    private enum Constants {
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 10
        static let font = UIFont(name: "AvenirNext-Medium", size: 22)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = BMColor.babyWhiteBackgroundColor
        layer.borderColor = BMColor.babyBlueLineColor.cgColor
        layer.borderWidth = Constants.borderWidth
        layer.cornerRadius = Constants.cornerRadius
        setTitle(title, for: .normal)
        setTitleColor(BMColor.babyBlueTextColor, for: .normal)
        setTitleColor(BMColor.babyBlueLineColor, for: .highlighted)
        titleLabel?.font = Constants.font
    }
    
    func setToNormalStyle(title: String) {
        isRecordingStyled = false
        backgroundColor = BMColor.babyWhiteBackgroundColor
        layer.borderColor = BMColor.babyBlueLineColor.cgColor
        setTitle(title, for: .normal)
        setTitleColor(BMColor.babyBlueTextColor, for: .normal)
        setTitleColor(BMColor.babyBlueLineColor, for: .highlighted)
    }
    
    func setToRecordStyle(title: String) {
        isRecordingStyled = true
        backgroundColor = BMColor.recordingRedColor
        layer.borderColor = BMColor.lightGrayLineColor.cgColor
        setTitle(title, for: .normal)
        setTitleColor(BMColor.babyWhiteBackgroundColor, for: .normal)
        setTitleColor(BMColor.lightGrayLineColor, for: .highlighted)
    }
    
}
