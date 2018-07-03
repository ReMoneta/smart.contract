module.exports = {
    skipFiles: ['Migrations.sol','/test/LockupContractTest.sol','/test/RETCrowdSaleTest.sol','/test/RETTokenTest.sol'],
    // need for dependencies
    copyNodeModules: true,
    copyPackages: ['zeppelin-solidity', 'minimetoken'],
    dir: '.',
    norpc: false
};
