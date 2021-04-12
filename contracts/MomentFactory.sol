// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MomentFactory is ERC721 {
	constructor() ERC721("Moment", "MMT") {}
	
    struct Moment {
		string url;
		string meta_url;
		uint created_at;
	}

	Moment[] public moments;

	modifier onlyOwnerOf(uint _tokenId) {
		require(msg.sender == ownerOf(_tokenId));
		_;
	}

	function createMoment (string memory _url, string memory _meta_url) public {
		moments.push(Moment(_url, _meta_url, block.timestamp));
		uint id = moments.length - 1;
		_mint(msg.sender, id);
	}

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalMoments = moments.length - 1;
            uint256 resultIndex = 0;
            uint256 momentId;

            for (momentId = 0; momentId <= totalMoments; momentId++) {
                if (ownerOf(momentId) == _owner) {
                    result[resultIndex] = momentId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
}