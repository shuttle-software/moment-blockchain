const OmentToken = artifacts.require('OmentToken');
const MomentMarket = artifacts.require('MomentMarket');

module.exports = function(deployer) {
  deployer.deploy(MomentMarket);
  deployer.deploy(OmentToken);
}