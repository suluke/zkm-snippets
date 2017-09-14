const path            = require('path');
const { exec }        = require('child_process');
const execp = (...args) => new Promise((res, rej) => {
  exec(...args, (err, stdout, stderr) => {
    if (err) {
      rej({err, stdout, stderr});
    } else {
      res({stdout, stderr});
    }
  })
});
const makeCmd = 'make --no-builtin-rules';

console.log('Build project before startup. This may take a while');
execp(makeCmd)
.then(startServer, ({err, stdout, stderr}) => {
  console.error(err);
  console.error(stdout);
  console.error(stderr);
  process.exit(-1);
});

function startServer() {
  const express         = require('express');
  const fs              = require('fs-extra');
  const prism           = require('prismjs');

  const PkgRoot         = __dirname;
  const StaticDir       = 'build';
  const StaticPath      = path.join(PkgRoot, StaticDir);

  // Static file server
  const statics = express.static(StaticPath);
  const server = express();
  // Call make
  server.use((req, res, next) => {
    execp(makeCmd)
    .then(() => next(), ({err, stdout, stderr}) => {
      console.log(`${stdout}`);
      console.log(`${stderr}`);
      res.status(500).send('Something\'s not right :/');
    });
  });
  // Resolve index.html
  server.use((req, res, next) => {
    if (req.url.endsWith('/')) {
      res.sendFile(path.join(PkgRoot, StaticDir, req.url, 'index.html'));
    } else {
      next();
    }
  });
  server.use(statics);
  server.listen(3000);
  console.log('Server is ready');
}
