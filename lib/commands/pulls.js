import Store from '../store';
import { pulls, verifyWhitelist } from '../github';
import { pullRequest as formatPullRequest } from '../formatter';

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
  console.log(pullRequests);
  const lines = pullRequests.map(formatPullRequest);

  return lines.join('\n');
}

function fetchOne(repo) {
  if (!verifyWhitelist(repo)) {
    return Promise.reject(new Error('Repository does not match whitelist.'));
  }
  return pulls(repo)
    .then(format);
}

function fetchAll() {
  const store = Store.instance();
  return store
    .listRepos()
    .then((repos) =>
      Promise.all(repos.map, (repo) => pulls(repo))
    )
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
