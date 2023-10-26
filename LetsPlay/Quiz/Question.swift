//
//  Question.swift
//  LetsPlay
//
//  Created by Maris Lagzdins on 30/06/2021.
//

import Foundation

struct Question: Codable {
    let question: String
    let answers: [String]
    let correctIndex: Int
}
