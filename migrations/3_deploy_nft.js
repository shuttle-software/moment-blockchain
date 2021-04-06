const MomentMarket = artifacts.require('MomentMarket');

module.exports = function(deployer) {
  deployer.deploy(MomentMarket);
}