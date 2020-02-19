import Vapor
import Fluent
import FluentSQLite

final public class LinkDBController {

    public static let shared = LinkDBController()

    public func allLinks(_ req: Request, completion: @escaping (Result<[Link], Error>) -> Void) {
        let promise = Link.query(on: req).all()
        promise.whenSuccess { links in
            completion(.success(links))
        }
        promise.whenFailure { error in
            completion(.failure(error))
        }
    }
    
    /// Returns a list of all `Link`s.
    public func index(_ req: Request) throws -> Future<[Link]> {
        return Link.query(on: req).all()
    }
    //
    //    /// Saves a decoded `Link` to the database.
    //    public func create(_ req: Request) throws -> Future<Link> {
    //        return try req.content.decode(Link.self).flatMap { todo in
    //            return todo.save(on: req)
    //        }
    //    }
    //
    //    /// Deletes a parameterized `Link`.
    //    public func delete(_ req: Request) throws -> Future<HTTPStatus> {
    //        return try req.parameters.next(Link.self).flatMap { todo in
    //            return todo.delete(on: req)
    //        }.transform(to: .ok)
    //    }

    /// Deletes a parameterized `Link`.
    public func deleteLink(_ req: Request) throws -> String {
        let twitterAccount = try req.query.get(String.self, at: "account")
        let existingLinks = Link.query(on: req).filter(\.twitterAccountName == twitterAccount).all()
        existingLinks.whenSuccess { links in
            links.forEach( { link in
                let result = link.delete(on: req)
                print(result)
            })
        }
        return "Deleted all links for \(twitterAccount)"
    }

    public func createLink(_ req: Request) throws -> String { //Future<[Link]> {
        do {
            let twitterAccount = try req.query.get(String.self, at: "account")
            let webhook = try req.query.get(String.self, at: "webhook")

            let existingLinks = Link.query(on: req).filter(\.twitterAccountName == twitterAccount).all()
            existingLinks.whenSuccess { links in
                print("existingLinks: \(links.count)")
                guard links.isEmpty else { return }
                let newLink = Link(
                    twitterAccountName: twitterAccount,
                    discordWebHook: webhook
                )

                let result = newLink.save(on: req)
                result.whenSuccess { _ in
                    print("LINK: created \(twitterAccount)")
                }

                result.whenFailure { error in
                    print("LINK: \(error)")
                }

            }

            return "✅ Linked `\(twitterAccount)` to `\(webhook)`"
        } catch {
            return error.localizedDescription
        }
    }

    public func tweetedTweets(_ req: Request, completion: @escaping (Result<[TweetedTweet], Error>) -> Void) {
        let existingTweets = TweetedTweet.query(on: req).all()
        existingTweets.whenSuccess { tweetedTweets in
            completion(.success(tweetedTweets))
        }
        existingTweets.whenFailure { error in
            completion(.failure(error))
        }
    }

    @discardableResult public func setTweeted(_ req: Request, tweetID: Int, completion: @escaping (Result<Void, Error>) -> Void) -> String { //Future<[Link]> {
        let existing = TweetedTweet.query(on: req).filter(\.tweetID == tweetID).all()
        existing.whenSuccess { tweets in
            let new = TweetedTweet(
                tweetID: tweetID
            )

            let result = new.save(on: req)
            result.whenSuccess { _ in
                print("TweetedTweet: created \(tweetID)")
                completion(.success(()))
            }
            result.whenFailure { error in
                print("LINK: \(error)")
                completion(.failure(error))
            }

        }
        return "✅ Saved tweeted tweet with ID \(tweetID)"
    }
}
