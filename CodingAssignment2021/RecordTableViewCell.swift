//
//  RecordTableViewCell.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/1/21.
//

import Anchorage
import UIKit

class RecordTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let dateLabelFont = UIFont(name: "AvenirNext-Medium", size: 20)
        static let intervalLabelFont = UIFont(name: "AvenirNext-Medium", size: 18)
        static let durationLabelFont = UIFont(name: "AvenirNext-Medium", size: 18)
        static let minimumScaleFactor: CGFloat = 0.5
    }
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.dateLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.textAlignment = .left
        label.textColor = BMColor.babyBlueTextColor
        return label
    }()
    
    private lazy var intervalLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.intervalLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.textAlignment = .left
        label.textColor = BMColor.lightGrayLineColor
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = Constants.durationLabelFont
        label.minimumScaleFactor = Constants.minimumScaleFactor
        label.textAlignment = .center
        label.textColor = BMColor.regularGrayLineColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(dateInterval: DateInterval) {
        dateLabel.text = FormattedStringManager.getCurrentDate()
        durationLabel.text = FormattedStringManager.getDuration(dateInterval: dateInterval)
        intervalLabel.text = FormattedStringManager.getInterval(dateInterval: dateInterval)
    }
    
}

// MARK: - UI setup
private extension RecordTableViewCell {
    
    func addSubviews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(intervalLabel)
        contentView.addSubview(durationLabel)
    }
    
    func setupConstraints() {
        
        // date label
        dateLabel.heightAnchor == contentView.safeAreaLayoutGuide.heightAnchor * 0.5
        dateLabel.leftAnchor == contentView.safeAreaLayoutGuide.leftAnchor + 8
        dateLabel.topAnchor == contentView.safeAreaLayoutGuide.topAnchor + 4
        dateLabel.widthAnchor == contentView.safeAreaLayoutGuide.widthAnchor * 0.55
        
        // interval label
        intervalLabel.bottomAnchor == contentView.safeAreaLayoutGuide.bottomAnchor - 4
        intervalLabel.heightAnchor == contentView.safeAreaLayoutGuide.heightAnchor * 0.5
        intervalLabel.leftAnchor == contentView.safeAreaLayoutGuide.leftAnchor + 8
        intervalLabel.widthAnchor == contentView.safeAreaLayoutGuide.widthAnchor * 0.55
        
        // duration label
        durationLabel.bottomAnchor == contentView.safeAreaLayoutGuide.bottomAnchor
        durationLabel.leftAnchor == intervalLabel.rightAnchor + 8
        durationLabel.rightAnchor == contentView.safeAreaLayoutGuide.rightAnchor - 8
        durationLabel.topAnchor == contentView.safeAreaLayoutGuide.topAnchor
        
    }
    
}
