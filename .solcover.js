module.exports = {
    skipFiles: ['Migrations.sol','/tests/LockupContractTest.sol','/tests/RETCrowdSaleTest.sol','/test/RETTokenTest.sol','/tests/MintableCrowdsaleOnSuccessAgentTest.sol','/tests/TimeLockedTest.sol','/tests/BlockLockedTest.sol','/tests/RCrowdsaleTest.sol'],
    // need for dependencies
    copyNodeModules: true,
    copyPackages: ['zeppelin-solidity', 'minimetoken'],
    dir: '.',
    norpc: false
};
