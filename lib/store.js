const redis = require('redis');

function redisKey(suffix) {
  return `slack-gh-extras:${suffix}`;
}

class Store {
  constructor(redisUrl) {
    this.redis = redis.createClient(redisUrl);
  }

  listRepos() {
    return new Promise((resolve, reject) => {
      redis.lrange(redisKey('repos'), 0, -1, (err, repos) => {
        if (err) {
          reject(err);
        } else {
          resolve(repos);
        }
      });
    });
  }

  addRepo(repoName) {
    return new Promise((resolve, reject) => {
      redis.rpush(redisKey('repos'), repoName, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }
}

let storeInstance = null;

Store.instance = function instance() {
  if (!instance) {
    storeInstance = new Store(process.env.REDIS_URL);
  }
  return storeInstance;
};

module.exports = Store;
