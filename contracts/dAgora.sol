/**
 * @title dAgora
 * @author Paul Szczesny
 * A decentralized marketplace
 */
contract dAgora {
	enum OrderStatus { New, Pending, Shipped, Cancelled, Refunded, Complete }

	// Data structure representing a generic product
	struct Product {
		bytes32 dph; // Decentralized Product Hash
		string title;
		string description;
		string category;
		uint price;
		uint stock;
	}
	struct Order {
		uint id;
		address customer;
		uint totalCost;
		bytes32 dph;
		OrderStatus status;
	}

	address public admin;
	mapping (bytes32 => Product) public productList;
	mapping (uint => bytes32) public productIndex;
	uint public productCount;
	mapping (address => mapping (uint => Order) ) public orderList;
	mapping (address => uint) public orderCount; // Maintains an order counter for each customer so that the orderList mapping can be iterated

	// Check whether the current transaction is coming from the administrator
	modifier isAdmin() {
		if(msg.sender != admin) throw;
		_
	}

	function dAgora() {
		admin = msg.sender;
	}

	function getProductCount() returns (uint counter) {
		return productCount;
	}

	function getProduct(uint index) returns (string title) {
		return productList[productIndex[index]].title;
	}

	/**
	 * Add a new product to the marketplace
	 * @param title A unique title for this product
	 * @param description A detailed description of this product
	 * @param category The main category this product falls under
	 * @param price The price of this product in Wei
	 * @param stock The beginning level of stock for this product
	 */
	function addProduct(string title, string description, string category, uint price, uint stock) returns (bool success){
		bytes32 dph = sha256(title, category, this, msg.sender, block.timestamp); // Create a new unique product ID
		uint nextIndex = productCount + 1;
		productList[dph] = Product(dph, title, description, category, price, stock);
		productIndex[nextIndex] = dph;
		productCount = nextIndex;
		return true;
	}

	/**
	 * Purchase a product via it's DPH
	 * @param dphCode The DPH associated with the product to purchase
	 */
	function buy(bytes32 dphCode) {
		uint price = productList[dphCode].price;
		if(msg.value < price) throw;
		if(msg.value > price) {
			if(!msg.sender.send(msg.value - price)) throw;
		}
		uint nextId = orderCount[msg.sender] + 1;
		orderList[msg.sender][nextId] = Order(nextId, msg.sender, price, dphCode, OrderStatus.New);
		orderCount[msg.sender]++;
		productList[dphCode].stock--;
	}

	/**
	 * Withdraw funds from the contract
	 * @param recipient The Address to withdraw funds to
	 * @param amount The amount of funds to withdraw in Wei
	 */
	function withdraw(address recipient, uint amount) isAdmin {
		if(!recipient.send(amount)) throw;
	}

	/**
	 * TODO
	 */
	function updateProductStock(bytes32 dphCode, uint newStock) isAdmin {

	}

	/**
	 * TODO
	 */
	function updateOrderStatus(bytes32 dphCode, OrderStatus status) isAdmin {

	}

	/**
	 * TODO
	 * @dev Need to deal with the fact that sequential numbered indexes are being used
	 */
	function removeProduct() isAdmin {

	}
}