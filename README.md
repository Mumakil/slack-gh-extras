# Slack GitHub extras

Missing Slack GitHub /commands.

## Installation

1. First you'll need to figure out where to run this application. A publicly accessible https-enabled environment that can run a Rails app is required. Heroku recommended. You'll need the would-be url for Slack configuration.
2. Go to Slack App & Integration management and navigate to `Build` -> `Make a Custom Integration` -> `Slash commands`.
3. In the wizard, type in `/github` and hit `Add Slash Command Integration`. You can choose any other command too if you like, but remember to configure it for your app later.
4. Configure the integration: For URL, the app's Slack /command endpoint is `/slack`, so if you're running the app in `https://myapp.herokuapp.com`, set the URL to `https://myapp.herokuapp.com/slack`. Method should be `POST`. Other fields like the identity you can configure as you wish. Take note of the `Token` variable.
5. Configure your app per next chapter.

## Configuration

Add the following environment variables for your app:

- `SLACK_COMMAND_TOKEN` - this is the token from Slack /command configuration and is used to authenticate that the webhooks are really from Slack.
- `SLACK_TEAM_DOMAIN` - your Slack Domain.
- `SLACK_COMMAND` - this needs to match the command you configured in Slack. `/github` is recommended.

## Usage

The `/github` command is available in all of your channels. `/github help` will tell you all of the available commands and their usage. The basics are like this:

- Introduce yourself by setting your GitHub access token. `/github token set MYTOKEN`. The app will always access GitHub using your own access token. You'll need to have the `repo` scope when you create the token.
- Create a repository list as an easy alias for a bigger list of repositories with `/github list add project-repos myorg/repo1 myorg/repo2`.
- You can query open pull requests in any repository you have access to with `/github prs myorg/repo`. Alternatively you can use any combination of repository lists or multiple repositories.
- You can set a default query for any channel with `/github default set myorg/repo1 project-repos`. That way you can just ask `/github prs` and the default query will be used.
- All of the commands work in public channels as well as in DMs.

## Licence

MIT (c) Otto Vehviläinen 2016
