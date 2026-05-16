
const http = require('http');
const port = 5001;
const server = http.createServer((req, res) => {
    res.end('ok');
});
server.on('error', (err) => {
    console.error('SERVER ERROR:', err.message);
    process.exit(1);
});
server.listen(port, () => {
    console.log('LISTENING ON', port);
    process.exit(0);
});
