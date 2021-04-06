// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20Permit.sol";

contract OmentToken is ERC20Permit, Ownable {
    constructor() ERC20Permit("OMENT", "OMENT", 2771) {
        _mint(msg.sender, 150000000 * 10 ** decimals());
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount * 10 ** decimals());
    }

    // Temp
	function kill() public onlyOwner {
        address payable wallet = payable(owner());
		selfdestruct(wallet);
	}
}