const MomentMarket = artifacts.require("MomentMarket");
const utils = require("./helpers/utils");
const { PERMIT_TYPEHASH, getPermitDigest, getDomainSeparator, sign } = require('../utils/signatureNFT');
// const time = require("./helpers/time");
var expect = require('chai').expect;

const testUrl = "http://example.com";
const metaUrl = "ipfs://QmQC1aikc3a6BsYNq8kSf25tLxT9MwWWUvVvFowbqroiiT";

contract("MomentMarket", (accounts) => {
    let [alice, bob] = accounts;
    const chainId = 2771;
    const alicePrivateKey = "0d91fdfe438b77e70d1d22b2f6e3ef07d154eedc104dcdf0ac6dea2739e57dc9";
    const ownerPrivateKey = Buffer.from(alicePrivateKey, 'hex')
    var name;

    let contractInstance;

    beforeEach(async () => {
        contractInstance = await MomentMarket.new();

        name = await contractInstance.name()
    });

    it("should be able to create a new nft", async () => {
        const result = await contractInstance.createMoment(testUrl, metaUrl, {from: alice});
        expect(result.receipt.status).to.equal(true);
        expect(result.logs[0].args.to).to.equal(alice);
    })

    it("Balance of alice shold be 1", async () => {
        await contractInstance.createMoment(testUrl, metaUrl, {from: alice});
        const length = await contractInstance.balanceOf(alice);
        expect(length.toNumber()).to.equal(1);
    })

    it("should transfer nft", async () => {
        const result = await contractInstance.createMoment(testUrl, metaUrl, {from: alice});
        const tokenId = result.logs[0].args.tokenId.toNumber();
        await contractInstance.transferFrom(alice, bob, tokenId, {from: alice});

        const newOwner = await contractInstance.ownerOf(tokenId);
        expect(newOwner).to.equal(bob);
    })

    it("should not transfer nft", async () => {
        const result = await contractInstance.createMoment(testUrl, metaUrl, {from: alice});
        const tokenId = result.logs[0].args.tokenId.toNumber();
        await utils.shouldThrow(contractInstance.transferFrom(alice, bob, tokenId, {from: bob}));
    })


    context("Testing permit", async () => {
        it("Get nonces, should be 0", async () => {
            const nonce = await contractInstance.nonces(alice);
    
            expect(nonce.toNumber()).to.equal(0);
        })
    
        it('initializes PERMIT_TYPEHASH correctly', async () => {
            expect(await contractInstance.PERMIT_TYPEHASH()).to.equal(PERMIT_TYPEHASH);
        })
    
        it('initializes DOMAIN_SEPARATOR correctly', async () => {
            expect(await contractInstance.DOMAIN_SEPARATOR()).to.equal(getDomainSeparator(name, contractInstance.address, chainId));
        })
    
        it('permits and emits Approval (replay safe)', async () => {
            // Create the approval request
            const approve = {
              owner: alice,
              url: "http://example.com",
              meta_url: "http://example.com",
            }
    
            const owner = approve.owner;
        
            // deadline as much as you want in the future
            const deadline = 0;
        
            // Get the user's nonce
            var nonceRes = await contractInstance.nonces(owner)
            const nonce = nonceRes.toNumber();
        
            // Get the EIP712 digest
            const digest = getPermitDigest(name, contractInstance.address, chainId, approve, nonce, deadline)
        
            // Sign it
            // NOTE: Using web3.eth.sign will hash the message internally again which
            // we do not want, so we're manually signing here
            const { v, r, s } = sign(digest, ownerPrivateKey)
    
            // Approve it
            const receipt = await contractInstance.permit(approve.owner, approve.url, approve.meta_url, nonce, deadline, v, r, s)
            const event = receipt.logs[0]
            const tokenId = event.args.tokenId.toNumber();
        
            // It worked!
            expect(event.event).to.equal('Transfer');
    
            var nonceRes = await contractInstance.nonces(owner)
    
            expect(nonceRes.toNumber()).to.equal(1);

            const newOwner = await contractInstance.ownerOf(tokenId);
            expect(newOwner).to.equal(owner);
        })
    })

    afterEach(async () => {
        await contractInstance.kill();
    });
})