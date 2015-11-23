import commands from './lib/commands';

process.env.SLACK_TEAM_DOMAIN = 'example_domain';
process.env.SLACK_COMMAND_TOKEN = 'example_token';
process.env.SLACK_COMMAND_CHANNEL = 'example_channel';

/* eslint camelcase: 0  */
const payload = {
  token: 'example_token',
  team_id: 'T0001',
  team_domain: 'example_domain',
  channel_id: 'example_channel',
  channel_name: 'Example',
  user_id: 'U2147483697',
  user_name: 'Steve',
  command: '/pulls',
  text: process.env.REPO_NAME,
};

commands['/pulls'](payload)
  .then((res) => console.log(res))
  .catch((err) => console.error(err, '\n', err.stack));
