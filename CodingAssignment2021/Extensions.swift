//
//  Extensions.swift
//  CodingAssignment2021
//
//  Created by Kousei Richeson on 2/3/21.
//

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
