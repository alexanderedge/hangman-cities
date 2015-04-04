# Hangman Cities Edition (Server)

The classic hangman game with a geographical twist. This server component is designed to be used in conjunction with the [iOS client](https://github.com/alexanderedge/hangman-cities-client).

## Assumptions

* Each game ends after 10 incorrect guesses
* Clients shouldn't be shown the word via the API
* Solo game; no login and no user accounts
* Hangman is the only game that will be played
* A-z (and space) are the only characters allowed in the game

## Installation Instructions

Build and run the [iOS client](https://github.com/alexanderedge/hangman-cities-client) and it will connect to a server already running on Heroku. If you wish to run it locally, you can do so by following these steps:

1. Run `bundle install` to install Ruby gems
2. Run `ruby hangman.rb` and Sinatra will start a local server
3. Change the iOS client base URL in Game.swift to the local server (default is `http://localhost:4567`)
4. Run the iOS client

The local server uses SQLite and Heroku deployment uses Postgres for persistence.

## Acknowledgements

This Sinatra server component is based on [https://github.com/sklise/sinatra-api-example](https://github.com/sklise/sinatra-api-example).
