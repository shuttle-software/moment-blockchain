const OmentToken = artifacts.require('OmentToken');

module.exports = function(deployer) {
  deployer.deploy(OmentToken);
}