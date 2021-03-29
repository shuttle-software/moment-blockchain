// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract ERC20Permit is ERC20 {
    mapping (address => uint256) public nonces;

	bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,uint256 amount)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(string memory name_, string memory symbol_, uint256 _chainId) ERC20(name_, symbol_) {
        // uint256 chainId;
        // assembly {
        //     chainId := chainid()
        // }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
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
		address spender, 
		uint256 nonce, 
		uint256 expiry,
        uint256 amount, 
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
					spender,
					nonce,
					expiry,
					amount
				)
			)
        ));

        require(holder != address(0), "invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "invalid-permit");
        require(expiry == 0 || block.timestamp <= expiry, "permit-expired");
        require(nonce == nonces[holder]++, "invalid-nonce");

		_approve(holder, spender, amount);
    }
}