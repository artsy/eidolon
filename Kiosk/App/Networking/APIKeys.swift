import Foundation
import Keys

private let minimumKeyLength = 2

// Mark: - API Keys

public struct APIKeys {
    let key: String
    let secret: String

    // MARK: Shared Keys

    private struct SharedKeys {
        static var instance = APIKeys()
    }

    public static var sharedKeys: APIKeys {
        get {
        return SharedKeys.instance
        }

        set (newSharedKeys) {
            SharedKeys.instance = newSharedKeys
        }
    }

    // MARK: Methods

    public var stubResponses: Bool {
        return key.characters.count < minimumKeyLength || secret.characters.count < minimumKeyLength
    }

    // MARK: Initializers

    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }

    public init(keys: EidolonKeys) {
        self.init(key: keys.artsyAPIClientKey() ?? "", secret: keys.artsyAPIClientSecret() ?? "")
    }

    public init() {
        let keys = EidolonKeys()
        self.init(keys: keys)
    }
}
