//
//  OtherFunctions.swift
//  Coins
//
//  Created by Adam on 8/2/17.
//  Copyright © 2017 Adam Eliezerov. All rights reserved.
//

import Foundation
import PhoneNumberKit

var fullPhoneNumber = String()

func recognizeNumber(phone: String) {
    let phoneNumberKit = PhoneNumberKit()
    do {
        let phoneNumber = try phoneNumberKit.parse(phone)
        let fullNumber = "+" + String(phoneNumber.countryCode) + phoneNumber.adjustedNationalNumber()
        print(fullNumber)
        fullPhoneNumber = fullNumber
    }
    catch {
        print("Generic parser error")
    }
}

