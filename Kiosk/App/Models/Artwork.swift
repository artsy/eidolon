import Foundation

// This is just  stub to do popover stuff with

public class Artwork: NSObject {
    let id:String
    var dateString:String?
    var title:String?
    var name:String?

    init(id: String) {
        self.id = id
        super.init()
    }
}
