import express from 'express';
import bodyParser from 'body-parser';

import hook from './lib/hook';

const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.post('/hook', hook);

const defaultPort = 3000;
const port = Number(process.env.PORT) || defaultPort;

const server = app.listen(port, () => {
  const host = server.address().address;

  console.log(`Server listening at http://${host}:${port}`);
});
