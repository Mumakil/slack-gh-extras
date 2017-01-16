import Slack from 'node-slack';

const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;

function client() {
  return new Slack(SLACK_WEBHOOK_URL);
}

export { client };
