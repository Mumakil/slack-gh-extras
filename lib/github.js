import octonode from 'octonode';
import { promisify } from './utils';

const GITHUB_API_TOKEN = process.env.GITHUB_API_TOKEN;
const GITHUB_REPO_PATTERN = new RegExp(process.env.GITHUB_REPO_PATTERN);

function client() {
  return octonode.client(GITHUB_API_TOKEN);
}

function repository(repo) {
  return promisify((callback) => client().repo(repo).info(callback));
}

function pulls(repo) {
  return promisify((callback) => client().repo(repo).prs(callback));
}

function verifyWhitelist(repo) {
  if (!repo.match(GITHUB_REPO_PATTERN)) {
    return false;
  }
  return true;
}

export { client, repository, pulls, verifyWhitelist };
