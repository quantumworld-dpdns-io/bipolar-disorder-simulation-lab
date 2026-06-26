module.exports = {
  experimental: {
    turbo: true,
  },
  eslint: {
    dirs: ['src'],
  },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-eval'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https://unpkg.com"],
      connectSrc: ["'self'", "wss:", "ws:", "https://api.quantumsynapse.local"],
      frameSrc: ["'self'", "https://quantumcloud.ibm.com"],
    },
  },
};