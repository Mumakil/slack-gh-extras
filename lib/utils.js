function promisify(callFn) {
  return new Promise((resolve, reject) => {
    callFn((err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
}

export { promisify };
