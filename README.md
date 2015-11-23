# slack-gh-extras
Missing Slack GitHub /commands

## Configuration

The following environment variables can be used to configure the app:

```
# A GitHub token that has access to the repositories you want to monitor.
GITHUB_API_TOKEN
# Comma separated list of repositories that can be queried.
GITHUB_REPOSITORIES
# The domain of your Slack team. Required.
SLACK_TEAM_DOMAIN
# The token from the /command configuration.
SLACK_COMMAND_TOKEN
# Id of the channel that the commands are allowed to be sent from.
SLACK_COMMAND_CHANNEL
# Webhook url that is used to respond to the queries.
SLACK_WEBHOOK_URL
```
