const MomentMarket = artifacts.require("MomentMarket");
const utils = require("./helpers/utils");
// const time = require("./helpers/time");
var expect = require('chai').expect;

const testUrl = "http://example.com";

contract("MomentMarket", (accounts) => {
    let [alice, bob] = accounts;

    let contractInstance;

    beforeEach(async () => {
        contractInstance = await MomentMarket.new();
    });

    it("should be able to create a new nft", async () => {
        const result = await contractInstance.createMoment(testUrl, {from: alice});
        expect(result.receipt.status).to.equal(true);
        expect(result.logs[0].args.to).to.equal(alice);
    })

    it("Balance of alice shold be 1", async () => {
        await contractInstance.createMoment(testUrl, {from: alice});
        const length = await contractInstance.balanceOf(alice);
        expect(length.toNumber()).to.equal(1);
    })

    it("should transfer nft", async () => {
        const result = await contractInstance.createMoment(testUrl, {from: alice});
        const tokenId = result.logs[0].args.tokenId.toNumber();
        await contractInstance.transferFrom(alice, bob, tokenId, {from: alice});

        const newOwner = await contractInstance.ownerOf(tokenId);
        expect(newOwner).to.equal(bob);
    })

    it("should not transfer nft", async () => {
        const result = await contractInstance.createMoment(testUrl, {from: alice});
        const tokenId = result.logs[0].args.tokenId.toNumber();
        await utils.shouldThrow(contractInstance.transferFrom(alice, bob, tokenId, {from: bob}));
    })

    afterEach(async () => {
        await contractInstance.kill();
    });
})