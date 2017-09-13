const express         = require('express');
const sass            = require('node-sass-middleware');
const fs              = require('fs-extra');
const path            = require('path');
const prism           = require('prismjs');
const { exec }        = require('child_process');

const PkgRoot         = __dirname;
const StaticDir       = 'build';
const StaticPath      = path.join(PkgRoot, StaticDir);

// Static file server
const statics = express.static(StaticPath);
const server = express();
// Call make
server.use((req, res, next) => {
  exec('make --no-builtin-rules', (err, stdout, stderr) => {
    if (err) {
      console.log(`${stdout}`);
      console.log(`${stderr}`);
      res.status(500).send('Something\'s not right :/');
    }
    next()
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
// Css compilation
const css = sass({
  src: 'scss',
  dest: StaticDir,
  root: PkgRoot,
  prefix: '/',
  outputStyle: 'extended',
  includePaths: [
    path.join(PkgRoot, 'node_modules')
  ]
});
server.use(css);
server.use(statics);
server.listen(3000);