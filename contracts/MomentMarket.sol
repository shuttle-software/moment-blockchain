// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.2;

import './NFTPermit.sol';
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MomentMarket is NFTPermit, Ownable {
	using EnumerableSet for EnumerableSet.UintSet;

	constructor() NFTPermit(2771) {}

	event OrderCreated(
		address indexed _seller,
		uint256 indexed _tokenId,
		uint256 _orderId
	);

	event OrderClosed(
		address indexed _seller,
		uint256 indexed _tokenId,
		uint256 _orderId
	);

	event OrderSuccessful(
		address indexed _seller,
		address indexed _buyer,
		uint256 indexed _tokenId,
		uint256 _orderId,
		uint256 _fee
	);

	struct Order {
		address seller;
		uint256 price;
		uint256 createdAt;
		string currency;
		uint tokenId;
		bool successful;
		bool closed;
	}

	Order[] public orders;

	mapping (uint256 => address) private _orderToOwner;
	mapping (address => EnumerableSet.UintSet) private _ownerOrders;

	modifier onlyOwnerOfOrder(uint _orderId) {
		require(msg.sender == address(0) && msg.sender == _orderToOwner[_orderId]);
		_;
	}
	modifier onlyOrderIsOpen(uint _orderId) {
		require(orders[_orderId].createdAt > 0 && orders[_orderId].closed == false);
		_;
	}

	function createOrder(
		uint256 _tokenId, 
		uint256 _price, 
		string memory _currency
	) 
		external 
		onlyOwnerOf(_tokenId) 
	{
		address _seller = msg.sender;
		Order memory _order = Order(
			_seller,
			_price,
			block.timestamp,
			_currency,
			_tokenId,
			false,
			false
		);

		orders.push(_order);
		uint _id = orders.length - 1;

		_orderToOwner[_id] = _seller;
		_ownerOrders[_seller].add(_id);

		_transfer(_seller, address(this), _tokenId);
		
		OrderCreated(
			_seller,
			_tokenId,
			_id
		);
  	}

	function closeOrder(
		uint256 _orderId
	)
		external
		onlyOwnerOfOrder(_orderId)
		onlyOrderIsOpen(_orderId)
	{
		Order storage _order = orders[_orderId];
		_order.closed = true;

		_transfer(address(this), msg.sender, _order.tokenId);

		OrderClosed(
			msg.sender,
			_order.tokenId,
			_orderId
		);
	}

	function buyOrder(
		uint256 _orderId
	)
		external
		payable
		onlyOrderIsOpen(_orderId)
	{
		_buyOrder(_orderId, msg.value);
		_transfer(address(this), msg.sender, orders[_orderId].tokenId);
	}

	function _buyOrder(
		uint256 _orderId,
		uint256 _amount
	)
		internal
	{
		Order storage _order = orders[_orderId];
		require(_amount >= _order.price);

		address _seller = _order.seller;
		uint256 _price = _order.price;
		uint256 _tokenId = _order.tokenId;

		_removeOrder(_orderId);

		// _order.closed = true;
		// _order.successful = true;


		if (_amount > 0) {
			// We'll be able to add fee
			transferMoney(_seller, _price);

			uint256 _difference = _amount - _price;
			if (_difference > 0) {
				transferMoney(msg.sender, _difference);
			}
		}

		OrderSuccessful(
			_seller,
			msg.sender,
			_tokenId,
			_orderId,
			0
		);
	}

	function _removeOrder(uint256 _orderId) internal {
		delete orders[_orderId];
		address owner = _orderToOwner[_orderId];
		_ownerOrders[owner].remove(_orderId);
		delete _orderToOwner[_orderId];
	}

	function transferMoney(address _to, uint256 _value) public {
		// address(uint160(_to)).transfer(_value);
		address payable wallet = payable(_to);
		wallet.transfer(_value);
		return;
	}

	// Temp
	function kill() public onlyOwner {
		address payable wallet = payable(owner());
		selfdestruct(wallet);
	}
}