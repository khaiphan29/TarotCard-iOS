//
//  CardManager.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 03/06/2022.
//

import Foundation
import UIKit

struct CardManager {
    private var cardFront: [UIImage] = []
    private var cardBack: UIImage
    var count: Int {
        return cardFront.count
    }
    init() {
        //Bundle interface returns path, no API to get content in the directory -> Use FileManager
        let pathToCardFront = Bundle.main.resourcePath! + "/src/cards"
        let pathToCardBack = Bundle.main.resourcePath! + "/src/cards back"
        let fileManager = FileManager.default
        
        //Set card front
        let cardFrontName = try! fileManager.contentsOfDirectory(atPath: pathToCardFront)
        for name in cardFrontName {
            cardFront.append(UIImage(contentsOfFile: pathToCardFront+"/"+name)!)
        }
        
        //Set card back
        let cardBackName = (try! fileManager.contentsOfDirectory(atPath: pathToCardBack))[0]
        cardBack = UIImage(contentsOfFile: "\(pathToCardBack)/\(cardBackName)")!
    }
    
    func getCardFront() -> [UIImage] {
        return cardFront
    }
    
    mutating func shuffle() {
        cardFront = cardFront.shuffled()
    }
    
    func getCardBack() -> UIImage {
        return cardBack
    }
}
