require "kemal"
require "./elm-chat/*"

messages = [] of JSON::Any
sockets  = [] of HTTP::WebSocket

public_folder "src/public"

get "/" do
  File.read("src/public/index.html")
end

ws "/chat-room" do |socket|

  sockets.push socket
  socket.send messages.to_json

  socket.on_message do |message|
    messages.push JSON.parse(message)

    sockets.each do |_socket|
      _socket.send messages.to_json
    end
  end

  socket.on_close do |_|
    puts "closing connection #{socket}"
    sockets.delete socket
  end
end

Kemal.run