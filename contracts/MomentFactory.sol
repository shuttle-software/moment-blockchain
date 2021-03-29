// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MomentFactory is ERC721 {
	constructor() ERC721("Moment", "MMT") {}
	
    struct Moment {
		string url;
		uint created_at;
	}

	Moment[] public moments;

	modifier onlyOwnerOf(uint _tokenId) {
		require(msg.sender == ownerOf(_tokenId));
		_;
	}

	function createMoment (string memory _url) public {
		moments.push(Moment(_url, block.timestamp));
		uint id = moments.length - 1;
		_mint(msg.sender, id);
	}
}