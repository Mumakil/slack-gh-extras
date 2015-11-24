import commands from './commands';
import { client as slackClient } from './slack';

const TEAM_DOMAIN = process.env.SLACK_TEAM_DOMAIN;
const TOKEN = process.env.SLACK_COMMAND_TOKEN;
const CHANNEL = process.env.SLACK_COMMAND_CHANNEL;

function validate(hookData, command) {
  if (TEAM_DOMAIN !== hookData.team_domain) {
    return Promise.reject(new Error('Invalid team domain.'));
  }
  if (TOKEN !== hookData.token) {
    return Promise.reject(new Error('Invalid token.'));
  }
  if (CHANNEL !== hookData.channel_id) {
    return Promise.reject(new Error('Invalid channel'));
  }
  return command.validate(hookData);
}

function hookRequest(req, res) {
  const hookData = req.body;
  const commandFn = commands[hookData.command];

  res.set('Content-Type', 'text/plain');
  if (!commandFn) {
    return res.send(400, 'No command given');
  }
  validate(hookData, commandFn)
    .catch((err) => res.status(500).send(err.message))
    .then(() => {
      res.status(200).send('Ok, processing.');
      process.nextTick(() => {
        commandFn(hookData)
          .then((response) => {
            console.log('SENDING\n\n', response);
            slackClient().send({ channel: hookData.channel_name, text: response });
          })
          .catch((err) => console.error('Error processing webhook:', err));
      });
    });
}

export default hookRequest;
