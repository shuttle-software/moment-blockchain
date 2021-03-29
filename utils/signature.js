const { keccak256, defaultAbiCoder, toUtf8Bytes, solidityPack } = require('ethers/lib/utils')
// const { BigNumberish, BigNumber } = require('ethers')
const { ecsign } = require('ethereumjs-util')

const sign = (digest, privateKey) => {
  return ecsign(Buffer.from(digest.slice(2), 'hex'), privateKey)
}

const PERMIT_TYPEHASH = keccak256(
  toUtf8Bytes('Permit(address holder,address spender,uint256 nonce,uint256 expiry,uint256 amount)')
)

// Returns the EIP712 hash which should be signed by the user
// in order to make a call to `permit`
const getPermitDigest = (
  name,
  address,
  chainId,
  approve,
  // approve: {
  //   owner: string
  //   spender: string
  //   value: BigNumberish
  // },
  nonce,
  deadline
) => {
  const DOMAIN_SEPARATOR = getDomainSeparator(name, address, chainId)
  // approve.value = BigNumber.from(approve.value);

  return keccak256(
    solidityPack(
      ['bytes1', 'bytes1', 'bytes32', 'bytes32'],
      [
        '0x19',
        '0x01',
        DOMAIN_SEPARATOR,
        keccak256(
          defaultAbiCoder.encode(
            ['bytes32', 'address', 'address', 'uint256', 'uint256', 'uint256'],
            [PERMIT_TYPEHASH, approve.owner, approve.spender, nonce, deadline, approve.value]
          )
        ),
      ]
    )
  )
}

// Gets the EIP712 domain separator
var getDomainSeparator = (name, contractAddress, chainId) => {
  return keccak256(
    defaultAbiCoder.encode(
      ['bytes32', 'bytes32', 'bytes32', 'uint256', 'address'],
      [
        keccak256(toUtf8Bytes('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)')),
        keccak256(toUtf8Bytes(name)),
        keccak256(toUtf8Bytes('1')),
        chainId,
        contractAddress,
      ]
    )
  )
}

exports.getDomainSeparator = getDomainSeparator;
exports.getPermitDigest = getPermitDigest;
exports.PERMIT_TYPEHASH = PERMIT_TYPEHASH;
exports.sign = sign;