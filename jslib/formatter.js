import moment from 'moment';

function pullRequest(pr) {
  const fullName = pr.base.repo.full_name;
  const number = pr.number;
  const title = pr.title;
  const owner = pr.user.login;
  const opened = pr.created_at;
  const formattedOpened = moment(opened).fromNow();
  const url = pr.html_url;
  const text = `<${url}|${fullName}#${number}> *${title}* _by ${owner}_, opened ${formattedOpened}`;
  return text;
}

export { pullRequest };
