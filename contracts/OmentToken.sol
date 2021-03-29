// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./ERC20Permit.sol";

contract OmentToken is ERC20Permit, Ownable {
    // using EnumerableSet for EnumerableSet.UintSet;

    constructor() ERC20Permit("OMENT", "OMENT", 2771) {
        _mint(msg.sender, 150000000 * 10 ** decimals());
    }

    // address market;

    // struct Transaction {
	// 	address buyer;
	// 	uint256 orderId;
	// 	uint256 createdAt;
	// 	string amount;
	// }

	// Transaction[] public transactions;

    // mapping (uint256 => address) private _transactionToOwner;
	// mapping (address => EnumerableSet.UintSet) private _ownerTransactions;

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount * 10 ** decimals());
    }

    // function setContract(address _address) public onlyOwner {
    //     market = _address;
    // }

    // function buyOrder(uint256 _orderId) public {
    //     bytes memory order = abi.encodeWithSignature("orders(uint)", _orderId);
    //     (bool success, bytes memory returnData) = address(market).call(order);
    //     require(success);

    //     _transfer(msg.sender, returnData.seller, returnData.price);

    //     Transaction memory _transaction = Transaction(
	// 		msg.sender,
	// 		_orderId,
	// 		block.timestamp,
	// 		returnData.price
	// 	);

    //     transactions.push(_transaction);

	// 	uint _id = transactions.length - 1;

	// 	_transactionToOwner[_id] = msg.sender;
	// 	_ownerTransactions[msg.sender].add(_id);
    // }

    // Temp
	function kill() public onlyOwner {
		selfdestruct(address(uint160(owner())));
	}
}