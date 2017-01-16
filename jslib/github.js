import octonode from 'octonode';
import { promisify } from './utils';

const GITHUB_API_TOKEN = process.env.GITHUB_API_TOKEN;

function client() {
  return octonode.client(GITHUB_API_TOKEN);
}

function repository(repo) {
  return promisify((callback) => client().repo(repo).info(callback));
}

function pulls(repo) {
  return promisify((callback) => client().repo(repo).prs(callback));
}

export { client, repository, pulls };
