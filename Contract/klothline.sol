// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

contract klothline{
    uint internal productsLength = 0;
    address payable public owner;
    enum KlothType{none, pants, shirts, dresses, skirts, shorts, shoes, headwear}

    struct product{
        KlothType klothtype;
        string image;
        string name;
        string size; 
        uint price;
        uint quantity;
        uint stock;
    }
    mapping (uint => product) internal products;


    constructor() payable {
        owner = payable(msg.sender);
    }


    modifier onlyOwner {
        require(owner == msg.sender, "only owner can perform this");
        _;
    }

    function addproduct( KlothType _klothtype, string memory _image, string memory _name, string memory _size, uint _price, uint _stock) public onlyOwner {
        uint _quantity = 0;
        products[productsLength] = product(
            _klothtype,
            _image,
            _name,
            _size,
            _price,
            _quantity,
            _stock
        );
        productsLength++;

    }


    function readProduct(uint _index) public view returns(KlothType, string memory, string memory, string memory, uint, uint, uint) {
        return (
            products[_index].klothtype,
            products[_index].image,
            products[_index].name,
            products[_index].size,
            products[_index].price,
            products[_index].quantity,
            products[_index].stock
        );

    }

    function getklothtypes() public pure returns (KlothType[] memory) {
        KlothType[] memory types = new KlothType[](7);
        types[0] = KlothType.pants;
        types[1] = KlothType.shirts;
        types[2] = KlothType.dresses;
        types[3] = KlothType.skirts;
        types[4] = KlothType.shorts;
        types[5] = KlothType.shoes;
        types[6] = KlothType.headwear;
        return types;
    }

    function purchaseproduct(uint _index)public payable{

        require(msg.value >= products[_index].price * products[_index].quantity, "Insufficient funds");
        require(products[_index].quantity >= products[_index].stock, "We are low on stock");
        
        // Perform the purchase
        if (msg.value > products[_index].price * products[_index].quantity) {
            uint refundAmount = msg.value - products[_index].price * products[_index].quantity;
            payable(msg.sender).transfer(refundAmount);
        }

        // Transfer the payment to the shop owner's account
        uint paymentAmount = products[_index].price * products[_index].quantity;
        owner.transfer(paymentAmount);
        products[_index].stock -= products[_index].quantity;
    }



    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }

}