import { pulls } from '../github';
import { pullRequest as formatPullRequest } from '../formatter';

const REPOSITORIES = process.env.GITHUB_REPOSITORIES.split(',');

function format(pullRequests) {
  if (pullRequests.length === 0) {
    return '_No open pull requests._';
  }
  pullRequests = pullRequests.sort((pra, prb) => {
    if (pra.created_at <= prb.created_at) {
      return -1;
    } else {
      return 1;
    }
  });

  const lines = pullRequests.map(formatPullRequest);

  return lines.join('\n');
}

function fetchOne(repo) {
  return pulls(repo)
    .then(format)
    .then((text) => `*Open pull requests for ${repo}:\n${text}`);
}

function fetchAll() {
  return Promise.all(REPOSITORIES.map((repo) => pulls(repo)))
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

function validate(hookData) {
  const repo = hookData.text;
  if (repo && repo.length > 0) {
    if (REPOSITORIES.map((str) => str.toLowerCase()).indexOf(repo.toLowerCase()) < 0) {
      return Promise.reject('Invalid repository.');
    } else {
      return Promise.resolve();
    }
  }
  return Promise.resolve();
}

pullCommand.validate = validate;

export default pullCommand;

export { fetchAll, fetchOne };
