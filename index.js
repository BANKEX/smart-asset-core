const TestRPC = require("ethereumjs-testrpc");
const { spawn } = require('child_process')
const config = require('./truffle-config');

TestRPC
    .server({
        logger: console
    })
    .listen(config.networks.development, function (err, blockchain) {
        spawn('npm', ['run', 'deploy'], { stdio: 'inherit' })
    });
