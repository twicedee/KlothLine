// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

contract Klothline {
    uint internal productsLength = 0;
    address payable public owner;
    
    enum KlothType { None, Pants, Shirts, Dresses, Skirts, Shorts, Shoes, Headwear }

    struct Product {
        KlothType klothType;
        string image;
        string name;
        string size; 
        uint price;
        uint stock;
        uint quantity;
    }
    
    mapping (uint => Product) internal products;

    event ProductAdded(
        uint indexed productId,
        KlothType klothType,
        string image,
        string name,
        string size,
        uint price,
        uint stock
    );

    event ProductPurchased(
        address indexed buyer,
        uint indexed productId,
        uint quantity,
        uint totalPrice
    );

    constructor() payable {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Only owner can perform this");
        _;
    }

    function addProduct(
        KlothType _klothType,
        string memory _image,
        string memory _name,
        string memory _size,
        uint _price,
        uint _stock
    ) public onlyOwner {
        products[productsLength] = Product(
            _klothType,
            _image,
            _name,
            _size,
            _price,
            _stock,
            0
        );
        emit ProductAdded(
            productsLength,
            _klothType,
            _image,
            _name,
            _size,
            _price,
            _stock
        );
        productsLength++;
    }

    function getProduct(uint _index) public view returns(
        KlothType,
        string memory,
        string memory,
        string memory,
        uint,
        uint,
        uint
    ) {
        require(_index < productsLength, "Invalid product index");
        return (
            products[_index].klothType,
            products[_index].image,
            products[_index].name,
            products[_index].size,
            products[_index].price,
            products[_index].stock,
            products[_index].quantity
        );
    }

    function getKlothTypes() public pure returns (KlothType[] memory) {
        KlothType[] memory types = new KlothType[](7);
        types[0] = KlothType.Pants;
        types[1] = KlothType.Shirts;
        types[2] = KlothType.Dresses;
        types[3] = KlothType.Skirts;
        types[4] = KlothType.Shorts;
        types[5] = KlothType.Shoes;
        types[6] = KlothType.Headwear;
        return types;
    }

    function purchaseProduct(uint _index, uint _quantity) public payable {
        require(_index < productsLength, "Invalid product index");
        require(_quantity > 0, "Quantity must be greater than 0");
        require(_quantity <= products[_index].stock, "Insufficient stock");
        
        uint totalPrice = products[_index].price * _quantity;
        require(msg.value >= totalPrice, "Insufficient funds");

        // Transfer the payment to the shop owner's account
        owner.transfer(totalPrice);

        // Refund excess payment
        uint refundAmount = msg.value - totalPrice;
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }

        // Update product quantity and stock
        products[_index].quantity += _quantity;
        products[_index].stock -= _quantity;

        emit ProductPurchased(msg.sender, _index, _quantity, totalPrice);
    }

    function getProductsLength() public view returns (uint) {
        return productsLength;
    }
}
