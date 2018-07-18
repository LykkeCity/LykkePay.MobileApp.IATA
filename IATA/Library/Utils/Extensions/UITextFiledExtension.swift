//
//  UITexyFiledExtension.swift
//  IATA
//
//  Created by Alexei Lazarev on 7/18/18.
//  Copyright © 2018 Елизавета Казимирова. All rights reserved.
//

import UIKit

extension UITextField {
    internal func filterNumbers(with string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if string != numberFiltered {
            return false
        }
        return true
    }
}
