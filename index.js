require("bulma/css/bulma.css")
const { Elm } = require("./elm/Main.elm")

const app = Elm.Main.init({
  flags: { url: "http://localhost:9000/elm-electron-app/" },
  node: document.getElementById('main')
})

const CONNECTION = {
  DISCONNECTED: Symbol("Disconnected"),
  CONNECTING: Symbol("Connectiong"),
  CONNECTED: Symbol("Connected"),
  DISCONNECTING: Symbol("Disconnecting")
}
let conn = CONNECTION.DISCONNECTED

// replace vendorId and productId to use your device
const vendorId = "065a"
const productId = "a002"
let serial
SerialPort.list().then(
  ports => ports.find(port => port.vendorId == vendorId && port.productId == productId),
  err => console.error(err)
).then(function(info) {
  const Readline = SerialPort.parsers.Readline
  const parser = new Readline({delimiter: '\r'})
  serial = new SerialPort(info.path, {autoOpen: false}) // invalid param will throw an error.
  serial.pipe(parser)
  serial.on('open', () => {
    conn = CONNECTION.CONNECTED
    console.log('SerialPort open')
    app.ports.serialConnection.send("切断")
  })
  serial.on('close', () => {
    conn = CONNECTION.DISCONNECTED
    console.log('SerialPort close')
    app.ports.serialConnection.send("接続")
  })
  parser.on('data', console.log)
})

app.ports.updateSerial.subscribe(function() {
  switch (conn) {
    case CONNECTION.DISCONNECTED:
      app.ports.serialConnection.send("接続中")
      conn = CONNECTION.CONNECTING
      serial.open(function(err) {
        if (err) {
          console.log("Error opening port: ", err.message)
        }
      })
      break;
    case CONNECTION.CONNECTED:
      app.ports.serialConnection.send("切断中")
      conn = CONNECTION.DISCONNECTING
      serial.close(function(err) {
        if (err) {
          console.log("Error closing port: ", err.message)
        }      
      })
      break;
  }
})
