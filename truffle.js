var HDWalletProvider = require("truffle-hdwallet-provider");
var infura_apikey = "IVdMmxgFJAKp7YDNqX4p";
var mnemonic = "belt twin client unfair sad hospital combine doll hood ready inherit direct";
//0xa63A25216352673bCc4024E569A97CDb1645FaBE - address

// const WalletProvider = require("truffle-wallet-provider");
// const Wallet = require('ethereumjs-wallet');
// var mainNetPrivateKey = new Buffer("some string", "hex")
// var mainNetWallet = Wallet.fromPrivateKey(mainNetPrivateKey);
// var mainNetProvider = new WalletProvider(mainNetWallet, "https://mainnet.infura.io/");

// const LightWalletProvider = require('@digix/truffle-lightwallet-provider')
// const lightWalletProvider = new LightWalletProvider({
//     keystore: '/path/to/json',
//     password: 'popcorn123!',
//     rpcUrl: config.infura.ethereum
// });

module.exports = {
    networks: {
        solc: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        },
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
        rinkeby: {
            provider: new HDWalletProvider(mnemonic, "http://94.130.216.246:8545/" + infura_apikey),
            gasPrice: 1000000000,
            network_id: 3,
            gas: 6000000
        },
        "live": {
            network_id: 1,
            // provider: mainNetProvider,
            // provider: lightWalletProvider,
            provider: null,
            // consider using higher prices to deploy quicker
            gasPrice: 1000000000,
            gas: 6000000
        }
    },
    // mocha: {
    //   reporter: 'mocha-multi-reporters',
    //   reporterOptions: {
    //       configFile: 'mocha-config.json'
    //   }
    // }
};