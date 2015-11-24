import { pulls } from '../github';
import { pullRequest as formatPullRequest } from '../formatter';

const REPOSITORIES = process.env.GITHUB_REPOSITORIES.split(',');

function format(pullRequests) {
  if (pullRequests.length === 0) {
    return '_No open pull requests._';
  }
  pullRequests.sort((pra, prb) => {
    if (pra.createdAt <= prb.createdAt) {
      return -1;
    }
    if (pra.createdAt > prb.createdAt) {
      return 1;
    }
  });

  const lines = pullRequests.map(formatPullRequest);

  return lines.join('\n');
}

function fetchOne(repo) {
  if (REPOSITORIES.map((str) => str.toLowerCase()).indexOf(repo.toLowerCase()) < 0) {
    return Promise.reject(new Error('Repository does not match whitelist.'));
  }
  return pulls(repo)
    .then(format)
    .then((text) => `*Open pull requests for ${repo}:\n${text}`);
}

function fetchAll() {
  Promise.all(REPOSITORIES.map, (repo) => pulls(repo))
    .then((result) => result.reduce((memo, arr) => memo.concat(arr), []))
    .then(format)
    .then((text) => `*All open pull requests:*\n${text}`);
}

function pullCommand(hookData) {
  if (hookData.text && hookData.text.length > 0) {
    return fetchOne(hookData.text);
  } else {
    return fetchAll();
  }
}

export default pullCommand;

export { fetchAll, fetchOne };
