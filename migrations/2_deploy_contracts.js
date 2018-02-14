var LegacyTree = artifacts.require("./cryptolegacy.sol");
module.exports = function(deployer) {
    deployer.deploy(web3.toWei(0.1, 'ether'), 100, {gas: 3000000});
};