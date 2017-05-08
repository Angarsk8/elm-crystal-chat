# Basic Chat - Elm + Crystal

Basic chat application developed with Elm and Crystal.

I decided not to use the [elm-lang/websocket](http://package.elm-lang.org/packages/elm-lang/websocket/1.0.2/WebSocket) package because I wanted to learn more about [ports](https://guide.elm-lang.org/interop/javascript.html) as a mechanism to interop with a JavaScript program to perform sync and async side effects.

## Development

* Start the application server with: `crystal src/elm-chat.cr`
* Start the frontend development server with: `npm start --prefix client/`

## Build

* Build and bundle the Elm project with: `npm run build --prefix client/`
* Compile application in release mode: `crystal build src/elm-chat.cr --release`

## Usage

* Run the release with: `./elm-chat --port <PORT_NUMBER>`