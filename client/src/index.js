import randomColor from 'randomcolor'
import Elm from './App.elm'
import './main.css'

function getApplicationHost(env) {
  return env === 'production'
    ? window.location.host
    : "localhost:3000"
}

const root = document.getElementById('root')
const app = Elm.App.embed(root, {
  host: getApplicationHost(process.env.NODE_ENV)
})

/* JavaScript Ports */

let socket

app.ports.loadUserData.subscribe(() => {
  const username = localStorage.getItem('username')
    || prompt('¿Cuál es tu nombre?')
    || 'Anonymous'

  const color = localStorage.getItem('color')
    || randomColor({luminosity: 'dark'})

  localStorage.setItem('username', username)
  localStorage.setItem('color' , color)

  app.ports.onUserData.send(JSON.stringify({ username, color }))
})

app.ports.connectSocket.subscribe(socketUrl => {
  socket = new WebSocket(socketUrl)

  socket.onmessage = e => {
    const messages = JSON.parse(e.data)
    app.ports.onMessages.send(JSON.stringify(messages))
  }

  socket.onopen = _ => {
    app.ports.onConnect.send("ok")
  }
})


app.ports.sendMessage.subscribe(message => {
  socket.send(message)
})