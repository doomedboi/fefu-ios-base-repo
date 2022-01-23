//
//  AuthRegHelpers.swift
//  fefuactivity
//
//  Created by soFuckingHot on 13.12.2021.
//

import Foundation
import UIKit

private let minLenOfPassword = 8
//  we should to operate with the crypte data but we wont
func checkPassCorrect(password: String) -> Bool {
    return password.count > minLenOfPassword  //  3a4em nam lishnii raz slat' na server shlak?
}


