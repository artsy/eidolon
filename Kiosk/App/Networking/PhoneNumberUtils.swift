import libPhoneNumber_iOS

let phoneNumberUtils = NBPhoneNumberUtil()

// The Kiosk is used in different regions with different phone number formatting. We use libPhoneNumber from Google to
// guess the E.164 format for the domestic numbers. This lets users enter in a number as if they were dialing it
// domestically, but we send it to Gravity as the full `+1 XX YYYYYY...` internatlized version. This helps make sure
// users receive SMS messages from Artsy about their bids, etc. If the parsing fails, we fall back to the number as the
// user entered it.
// See for more info: https://support.twilio.com/hc/en-us/articles/223183008-Formatting-International-Phone-Numbers
func formatPhoneNumberForRegion(_ numberInput: String, specifiedInDefaults defaults: UserDefaults = .standard) -> String {
    let region = defaults.string(forKey: PhoneNumberRegionKey) ?? "US" // shouldn't be nil because we register defaults in AppDelegate, but compiler.
    do {
        let phoneNumber = try phoneNumberUtils.parse(numberInput, defaultRegion: region)
        return try phoneNumberUtils.format(phoneNumber, numberFormat: .E164)
    } catch let error as NSError {
        logger.log("Failed to parse phone number '\(numberInput)' with region '\(region)'. Falling back to input. Error: \(error)")
        return numberInput
    }
}
