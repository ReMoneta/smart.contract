module.exports = {
  networks: {
    development: {
       host: "localhost",
       port: 8545,
       network_id: "*",
       gas: 4612388
    },
    coverage: {
      host: "localhost",
      network_id: "*",
      port: 8555,         // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffffff, // <-- Use this high gas value
      gasPrice: 0x01      // <-- Use this low gas price
    },
  },
  // mocha: {
  //   reporter: 'mocha-multi-reporters',
  //   reporterOptions: {
  //       configFile: 'mocha-config.json'
  //   }
  // }
};