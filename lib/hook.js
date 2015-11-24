import commands from './commands';
import { client as slackClient } from './slack';
import _ from 'lodash';

const TEAM_DOMAIN = process.env.SLACK_TEAM_DOMAIN;
const TOKEN = process.env.SLACK_COMMAND_TOKEN;
const CHANNEL = process.env.SLACK_COMMAND_CHANNEL;

function validate(hookData) {
  if (TEAM_DOMAIN !== hookData.team_domain) {
    return Promise.reject(new Error('Invalid team domain.'));
  }
  if (TOKEN !== hookData.token) {
    return Promise.reject(new Error('Invalid token.'));
  }
  if (CHANNEL !== hookData.channel_id) {
    return Promise.reject(new Error('Invalid channel'));
  }
  return Promise.resolve(true);
}

function hookRequest(req, res) {
  const hookData = req.body;
  const commandFn = commands[hookData.command];

  res.set('Content-Type', 'text/plain');
  if (!commandFn) {
    return res.send(400, 'No command given');
  }
  validate(hookData)
    .then(() => res.send(200, ''))
    .catch((err) => res.send(500, err.message))
    .then(() => commandFn(hookData))
    .then((response) =>
      slackClient().send(
        _.extend({ channel: hookData.channel_name }, response)
      )
    )
    .catch((err) => console.error('Error processing webhook:', err));
}

export default hookRequest;
