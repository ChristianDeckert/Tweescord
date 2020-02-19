import Vapor
import Console
import Command

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    router.get("quit") { _ -> String in
        currentApplication.shutdownGracefully({ error in
            print("stopping app with error: \(String(describing: error))")
            exit(error == nil ? 0 : Int32((error as NSError?)?.code ?? -999))
        })
        return "⏹ Quitting application..."
    }

    router.get("start") { req -> String in
        guard let jobEngine = currentApplication.providers.compactMap({ $0 as? JobEngine }).first else {
            print("JobEngine is missing")
            return "failed to load job engine"
        }

        let now = try? req.parameters.next(String.self)
        jobEngine.start(autoStart: now == "now")
        return "✅ started job \(now == "now" ? "immediately" : "delayed")"
    }

    router.get("stop") { _ -> String in
        guard let jobEngine = currentApplication.providers.compactMap({ $0 as? JobEngine }).first else {
            print("JobEngine is missing")
            return "failed to load job engine"
        }
        jobEngine.stop()
        return "🛑 stopped job..."
    }

    router.get("execute") { req -> String in
        guard let jobEngine = currentApplication.providers.compactMap({ $0 as? JobEngine }).first else {
            print("JobEngine is missing")
            return "failed to load job engine"
        }
        jobEngine.iterateLinksAndSendTweets(req: req)
        return "executing all jobs"
    }

    router.get("discord", String.parameter) { req -> String in

        guard let discordProvider = currentApplication.providers.compactMap({ $0 as? DiscordProvider }).first else {
            return "TweetProvider is missing"
        }

        let message = try req.parameters.next(String.self)
        return discordProvider.send(username: "Discord Test", message: message, avatarURL: nil, webhook: TestWebHooks.testChannel)
    }

    router.get("twurl", String.parameter) { req -> String in
        guard let tweetProvider = currentApplication.providers.compactMap({ $0 as? TweetProvider }).first else {
            return "TweetProvider is missing"
        }

        var resultString = ""
        do {
            let usernameArgument = try req.parameters.next(String.self)
            resultString = tweetProvider.retrieveTweets(username: usernameArgument) { result in
                switch result {
                case .success(let tweets):

//                    guard let latestNotRetweetedTweet = tweets.statuses.first(where: { !$0.retweeted && $0.containsURL }) else { break }
//                    guard let discordProvider = currentApplication.providers.compactMap({ $0 as? DiscordProvider }).first else {
//                        break
//                    }
//
//                    resultString = discordProvider.send(username: usernameArgument, message: latestNotRetweetedTweet.full_text, avatarURL: latestNotRetweetedTweet.user?.profile_image_url, webhook: TestWebHooks.testChannel)
                    break
                case .failure(let error):
                    print(error)
                }
            }
            return resultString
        } catch {
            return error.localizedDescription
        }
    }

    // Example of configuring a controller
    let linkDBController = LinkDBController()
    router.get("links", use: linkDBController.index)
//    router.post("link", use: linkDBController.create)
//    router.delete("link", Link.parameter, use: linkDBController.delete)
    router.get("createlink", use: linkDBController.createLink)
    router.get("deletelink", use: linkDBController.deleteLink)

}

extension Tweet {
    var containsURL: Bool {
        return !(extended_entities?.media?.compactMap({ $0.url }).isEmpty ?? true)
    }
}
