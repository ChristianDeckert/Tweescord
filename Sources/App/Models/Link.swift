import FluentSQLite
import Vapor

/// A single entry of a Link list.
public final class Link: SQLiteModel {
    /// The unique identifier for this `Link`.
    public var id: Int?

    /// A title describing what this `Link` entails.
    public var twitterAccountName: String
    public var discordWebHook: String

    /// Creates a new `Link`.
    public init(id: Int? = nil, twitterAccountName: String, discordWebHook: String) {
        self.id = id
        self.twitterAccountName = twitterAccountName
        self.discordWebHook = discordWebHook
    }
}

/// Allows `Link` to be used as a dynamic migration.
extension Link: Migration { }

/// Allows `Link` to be encoded to and decoded from HTTP messages.
extension Link: Content { }

/// Allows `Link` to be used as a dynamic parameter in route definitions.
extension Link: Parameter { }
