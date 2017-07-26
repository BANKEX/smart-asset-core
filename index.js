const TestRPC = require("ethereumjs-testrpc");
const { spawn } = require('child_process');
const config = require('./truffle-config');

TestRPC
    .server({
        logger: console
    })
    .listen(config.networks.development, (err, blockchain) =>
        spawn('npm', ['run', 'deploy'], { stdio: 'inherit', detached: true }));
