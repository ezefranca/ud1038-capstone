//
//  RandomWords.swift
//  ud1038-capstone
//
//  Created by Ezequiel on 11/11/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import Foundation

fileprivate extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

public class RandomPhrase {
    
    static let commom = [
        "They say this is ",
        "I just come from a ",
        "Bright lights, city life a ",
        "This is where it goes down, a ",
        "Snap back to ",
        "oh there goes ",
        "The souls escaping from ",
        "Lonely ",
        "Yo Yo, hey ho! ",
        "If I Say Ya, You Say Ye ",
        "Come one, come on ",
        "Look the ",
        "Is like the ",
        "I say ",
        "And you say "]
    
    static func randomWord() -> String {
        if let word = self.commom.randomItem() {
            return word
        }
        return ""
    }
        
        

    
    
}
