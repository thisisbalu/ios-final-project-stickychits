//
//  Utils.swift
//  StickyChits
//
//  Created by Bala on 29/11/20.
//  Copyright © 2020 Bala. All rights reserved.
//

import Foundation

class Utils {
    
    public static let shared = Utils()
    
    func randomString(type: String) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return type + "_" + String((0..<32).map{ _ in letters.randomElement()! })
    }
}
