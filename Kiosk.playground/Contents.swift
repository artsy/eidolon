//: Playground - noun: a place where people can play

import UIKit
import libPhoneNumber_iOS

var str = "Hello, playground"

let input = "+15555555555"

let utils = NBPhoneNumberUtil()
let phoneNumber = try utils.parse(input, defaultRegion: "GB")
print(try utils.format(phoneNumber, numberFormat: .E164))
