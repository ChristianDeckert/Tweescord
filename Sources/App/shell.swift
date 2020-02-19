//
//  shell.swift
//  App
//
//  Created by Christian on 13.02.20.
//

import Foundation


public enum ShellCommand {
    case twurl(username: String, numberOfTweets: UInt)

    var arguments: [String] {
        switch self {
        case let .twurl(username, numberOfTweets):
            let args = "'/1.1/search/tweets.json?q=\(username)&since_id=1034434925712171009&&count=\(numberOfTweets)&result_type=popular&tweet_mode=extended'"
//            let args = "'/1.1/search/tweets.json?q=PlayStation&since_id=1034434925712171009&&count=1&result_type=recent&tweet_mode=extended'"
            return ["~/.rvm/gems/ruby-2.4.0/bin/twurl \(args)"]
        }
    }
}

public struct ShellResult {
    let output: String
    let returnCode: Int
}

public func shell(command: ShellCommand) -> ShellResult {
    return shell(arguments: command.arguments)
}

public func shell(launchPath: String = "/bin/zsh", arguments: [String] = []) -> ShellResult {

    let task = Process()
    task.launchPath = launchPath

    task.arguments = ["-c", "--login"] + arguments

    var env =  ProcessInfo().environment
    var path = env["PATH"] ?? "/Users/christian/"
    path += ":/Users/christian/.rvm/gems/ruby-2.4.0/bin"
    path += ":/Users/christian/.rvm/scripts/rvm"
    path += ":/Users/christian/.rvm/gems/ruby-2.4.0/gems/twurl-0.9.5/bin"
    path += ":/Users/christian/.rvm/rubies/ruby-2.4.0/bin/ruby"
    path += ":/Users/christian/.rvm/rubies/Default/bin/ruby"
    path += ":/usr/local/bin"
    path += ":/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0/bin"
    env["PATH"] = path

    task.environment = env

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    do {
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        task.waitUntilExit()
        return ShellResult(output: output ?? "{}", returnCode: Int(task.terminationStatus))
    } catch {
        print("Error: \(error.localizedDescription)")
        return ShellResult(output: error.localizedDescription, returnCode: -999)
    }


}
