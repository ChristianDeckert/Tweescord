## Tweescord

Abusing a server side Swift app to forward a users popular tweets to a discord server/channel once per hour :-)

#### Prequesites
- Twitter developer account & app
- A Discord server with channels
- Xcode 
- Twurl `https://github.com/twitter/twurl`
- Ruby 2.4.0
- zsh / macOS catalina
- Vapor `https://vapor.codes`

#### Run

- start Xcode and run
- open Safari and navigate to `http://localhost:8080/`

#### Create a link (Twitter to Discord channel)

GET Request via Safari
`http://localhost:8080/createlink?account=TWITTERUSERNAME&webhook=https://discordapp.com/api/webhookFOO`

#### List all stored links

GET Request via Safari
`http://localhost:8080/links`

#### Start "Job"

Start fetching tweets in an hour:
`http://localhost:8080/start`

Start and fetch tweets immediately:
`http://localhost:8080/start/now`

#### Stop "Job"

Stop fetching tweets:
`http://localhost:8080/stop`

#### Delete a Twitter-Discord-link:

`http://localhost:8080/deletelink?account=TWITTERUSERNAME`
(case sensitive)

#### Dev: force execute all jobs

`http://localhost:8080/execute`

#### Dev: fetching tweets.json via twurl

`http://localhost:8080/twurl/TWITTERUSERNAME`

#### Notes

SQLite Database is stored at `~/Tweescord/database`
