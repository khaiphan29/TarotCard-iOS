//
//  messageData.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 02/06/2022.
//

import Foundation
struct ErrorMessageData: Codable {
    let error: ErrorData
}

struct ErrorData: Codable {
    let code: Int
    let message: String
}
