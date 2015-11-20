const commands = require('./commands');

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

module.exports = (req, res) => {
  const hookData = req.body();
  const commandFn = commands[hookData.command];

  res.set('Content-Type', 'text/plain');
  if (!commandFn) {
    return res.send(400, 'No command given');
  }
  validate(hookData)
    .then(() => commandFn(hookData))
    .then((responseText) => res.send(200, responseText))
    .catch((err) => res.send(500, err.message));
};

