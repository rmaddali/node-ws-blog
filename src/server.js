const WebSocket = require("ws");
const name = require("./randomName");
const server = require("http").createServer();
const express = require("express");
const app = express();

console.log(`This server is named: ${name}`);

// serve files from the public directory
server.on("request", app.use(express.static("public")));

// tell the WebSocket server to use the same HTTP server
const wss = new WebSocket.Server({
  server,
});

wss.on("connection", function connection(ws, req) {
  const clientId = req.url.replace("/?id=", "");
  console.log(`Client connected with ID: ${clientId}`);

  let n = 0;
  const interval = setInterval(() => {
    ws.send(`${name}: you have been connected for ${n++} seconds`);
  }, 1000);

  ws.on("close", () => {
    clearInterval(interval);
  });
});

const port = process.env.PORT || 80;
server.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});





// Expose websockets_connections_total prometheus metric on port 9095

const client = require('prom-client');

const register = new client.Registry();

register.setDefaultLabels({
  app: 'example-nodejs-app'
})



const cMetric=new client.Gauge({
  name: 'myapp_websockets_connections_total',
  help: 'myapp_websockets_connections_total_help',
  collect() {
    // Invoked when the registry collects its metrics' values.
    // This can be synchronous or it can return a promise/be an async function.
    this.set(wss.clients.size, register);
  },
});
register.registerMetric(cMetric);

app.get('/metrics', async (req, res) => {
   
    res.setHeader('Content-Type', register.contentType);
    let metrics = await register.metrics();
    res.end(metrics);
});
