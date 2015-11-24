# slack-gh-extras

Missing Slack GitHub /commands. 

Currently only `/pulls` command to display your repo's open pull requests in your Slack channel.

## Setup

1. Create new Heroku app so you have a url for step 3.
2. Go to your Slack channel and open up "Add a service integration". Search for `slash commands` and add new. 
3. Set `Command` to `/pulls`, `URL` to the hostname from step 1 plus `/hook`, `method` to `POST` and take note of the `Token` for last step. Hit `Save Integration`.
4. Go back to the Integrations adding and create an incoming web hook. Choose channel and take not of the Webhook URL for the last step.
5. Deploy your app to Heroku and add the environment variables from `Configuration` section.

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

## Usage

You can then use `/pulls` to list all open pull requests in the configured repositories or `/pulls org/repo` to list open pulls for that repo only.
