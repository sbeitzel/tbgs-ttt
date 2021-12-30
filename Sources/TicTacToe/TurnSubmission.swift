//
//  TurnSubmission.swift
//  
//
//  Created by Stephen Beitzel on 12/28/21.
//

import Foundation

struct TurnSubmission: Codable {
    let player: UUID
    let sequenceNumber: Int
    let square: Int
}
