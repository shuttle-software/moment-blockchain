// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.2;

import "./MomentFactory.sol";

abstract contract NFTPermit is MomentFactory {
    uint cooldownTime = 1 days;

    mapping (address => uint256) public nonces;
    mapping (address => uint256) public lastCreated;

	bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder, string memory _url, string memory _meta_url, uint256 nonce, uint256 expiry)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(uint256 _chainId) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes(version())),
                _chainId,
                address(this)
            )
        );
    }

    /// @dev Setting the version as a function so that it can be overriden
    function version() public pure virtual returns(string memory) { return "1"; }

	// --- Approve by signature ---
    function permit(
		address holder, 
        string memory _url, 
        string memory _meta_url,
		uint256 nonce,
		uint256 expiry,
		uint8 v, 
		bytes32 r, 
		bytes32 s
	) 
		external
    {
        bytes32 digest = keccak256(abi.encodePacked(
			"\x19\x01",
			DOMAIN_SEPARATOR,
			keccak256(
				abi.encode(
					PERMIT_TYPEHASH,
					holder,
					_url,
                    _meta_url,
					nonce,
					expiry
				)
			)
        ));

        require(holder != address(0), "invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "invalid-permit");
        require(expiry == 0 || block.timestamp <= expiry, "permit-expired");
        require(nonce == nonces[holder]++, "invalid-nonce");
        require(cooldownTime < block.timestamp - lastCreated[holder], "cooldown-not-expire");

		createMoment(_url, _meta_url);
        lastCreated[holder] = block.timestamp;
    }
}