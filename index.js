const http = require('http');
const PORT = process.env.PORT || 3000;
http.createServer((_, res) => res.end('ShadowDEX Escrow up\n'))
  .listen(PORT, () => console.log('Listening on :' + PORT));
