import redis from 'redis';
import { promisify } from './utils';

const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';

function redisKey(suffix) {
  return `slack-gh-extras:${suffix}`;
}

class Store {
  constructor(redisUrl) {
    this.redis = redis.createClient(redisUrl);
  }

  listRepos() {
    return promisify((callback) => redis.smembers(redisKey('repos'), 0, -1, callback));
  }

  addRepo(repoName) {
    return promisify((callback) => redis.sadd(redisKey('repos'), repoName, callback));
  }

  removeRepo(repoName) {
    return promisify((callback) => redis.srem(redisKey('repos'), repoName, callback));
  }
}

let storeInstance = null;

Store.instance = function instance() {
  if (!instance) {
    storeInstance = new Store(REDIS_URL);
  }
  return storeInstance;
};

export default Store;
