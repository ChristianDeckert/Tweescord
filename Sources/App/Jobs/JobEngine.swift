//
//  JobEngine.swift
//  App
//
//  Created by Christian on 14.02.20.
//

import Vapor
import Jobs

public final class JobEngine: Provider {

    public var isStarted: Bool { job != nil }
    public var lastExecuted: Date?
    private var job: Job?

    public func register(_ services: inout Services) throws {

    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        .done(on: container)
    }

    func start(interval: Double = 3600, autoStart: Bool = true) {
        guard !isStarted else { return }
        job = Jobs.add(interval: .seconds(interval), autoStart: autoStart, action: sendExecuteJobsRequest)
    }

    func stop() {        
        job?.stop()
        job = nil
    }

    func sendExecuteJobsRequest() {

        do {
            let client = try currentApplication.make(Client.self)
            _ = client.get(URL(string: "http://localhost:8080/execute")!)

        } catch {

        }
    }

    public func iterateLinksAndSendTweets(req: Request) {
        lastExecuted = Date()
        LinkDBController.shared.tweetedTweets(req) { result in

            switch result {
            case .success(let tweetedTweets):
                LinkDBController.shared.allLinks(req) { result in
                    switch result {
                    case .success(let links):

                        self.execureTweetJobs(allLinks: links, tweetedTweets: tweetedTweets, req: req)

                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure:
                break
            }
        }
    }

    private func execureTweetJobs(allLinks: [Link], tweetedTweets: [TweetedTweet], req: Request) {
        DispatchQueue(label: "tweet-job-queue").async {
            guard let tweetProvider = currentApplication.providers.compactMap({ $0 as? TweetProvider }).first else {
                return
            }

            guard let discordProvider = currentApplication.providers.compactMap({ $0 as? DiscordProvider }).first else {
                return
            }

            let dispatchGroup = DispatchGroup()
            allLinks.forEach { link in
                dispatchGroup.enter()
                print("Fetching tweets for job \(link.twitterAccountName)")
                _ = tweetProvider.retrieveTweets(username: link.twitterAccountName) { result in
                    switch result {
                    case .success(let tweets):
                        guard
                            let latestNotRetweetedTweet = tweets.statuses.first(where: { aTweet in
                                !aTweet.retweeted
                                && aTweet.containsURL
                                && aTweet.in_reply_to_screen_name == nil
                                && !tweetedTweets.contains(where: { $0.tweetID == aTweet.id })
                        }) else {
                                print("  '---> no tweets found")
                                dispatchGroup.leave()
                                break
                        }
                        print("  '---> sending tweet with ID \(latestNotRetweetedTweet.id)")
                        let _ = discordProvider.send(
                            username: link.twitterAccountName,
                            message: latestNotRetweetedTweet.full_text,
                            avatarURL: latestNotRetweetedTweet.user?.profile_image_url,
                            webhook: link.discordWebHook
                        )
                        LinkDBController.shared.setTweeted(req, tweetID: latestNotRetweetedTweet.id) { _ in
                            dispatchGroup.leave()
                        }

                    case .failure(let error):
                        print(error)
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.wait()
            }

            dispatchGroup.notify(queue: .main) {
                print("Executed all tweet jobs")
            }
        }
    }
}
