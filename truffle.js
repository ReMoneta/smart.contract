var HDWalletProvider = require("truffle-hdwallet-provider");
var infura_apikey = "IVdMmxgFJAKp7YDNqX4p";
var mnemonic = "belt twin client unfair sad hospital combine doll hood ready inherit direct";
//0xa63A25216352673bCc4024E569A97CDb1645FaBE - address
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
        rinkeby: {
            provider: new HDWalletProvider(mnemonic, "http://94.130.216.246:8545/" + infura_apikey),
            gasPrice: 1000000000,
            network_id: 3,
            gas: 6000000
        },
        // rinkeby: {
        //     provider: function() {
        //         new HDWalletProvider(mnemonic, "http://94.130.216.246:8545/"+infura_apikey)
        //     },
        //     gasPrice: 1000000000,
        //     network_id: 3,
        //     gas: 6000000
        // }
    },
    // mocha: {
    //   reporter: 'mocha-multi-reporters',
    //   reporterOptions: {
    //       configFile: 'mocha-config.json'
    //   }
    // }
};