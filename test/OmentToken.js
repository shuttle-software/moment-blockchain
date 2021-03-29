const OmentToken = artifacts.require("OmentToken");

var expect = require('chai').expect;
const utils = require("./helpers/utils");

const { PERMIT_TYPEHASH, getPermitDigest, getDomainSeparator, sign } = require('../utils/signature');


contract("OmentToken", (accounts) => {
    let [alice, bob] = accounts;
    const chainId = 2771;
    const alicePrivateKey = "0d91fdfe438b77e70d1d22b2f6e3ef07d154eedc104dcdf0ac6dea2739e57dc9";
    const ownerPrivateKey = Buffer.from(alicePrivateKey, 'hex')
    var name;

    let contractInstance;

    beforeEach(async () => {
        contractInstance = await OmentToken.new();

        name = await contractInstance.name()
    });

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
          spender: bob,
          value: 100, // 100
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
        const receipt = await contractInstance.permit(approve.owner, approve.spender, nonce, deadline, approve.value, v, r, s)
        const event = receipt.logs[0]
    
        // It worked!
        expect(event.event).to.equal('Approval');

        var nonceRes = await contractInstance.nonces(owner)

        expect(nonceRes.toNumber()).to.equal(1);
        expect(Number(await contractInstance.allowance(approve.owner, approve.spender))).to.equal(approve.value);
    })

    afterEach(async () => {
        await contractInstance.kill();
    });
})