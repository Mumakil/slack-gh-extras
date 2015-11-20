const express = require('express');
const bodyParser = require('body-parser');

const hook = require('./hook');

const app = express();

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

app.post('/hook', hook);

const defaultPort = 3000;
const port = Number(process.env.PORT) || defaultPort;

const server = app.lister(port, () => {
  const host = server.address().address;

  console.log(`Server listening at http://${host}:${port}`);
});
