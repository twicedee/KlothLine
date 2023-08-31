// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Klothline {
    address internal CeloTokenAddress = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9; //Celo token address for the transactions
    uint internal productsLength = 0;
    address payable public owner;

    //Kloth types being sold at the shop
    enum KlothType {
        None,
        Pants,
        Shirts,
        Dresses,
        Skirts,
        Shorts,
        Shoes,
        Headwear
    }

    //struct of the product being sild
    struct Product {
        KlothType klothType;
        string image;
        string name;
        string size;
        uint price;
        uint stock;
        uint quantity;
    }

    mapping(uint => Product) internal products;

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

    //Setting the owner to be the one to modify the contract
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can perform this");
        _;
    }


    function addProduct(
        KlothType _klothType,  //Type of kloth being Added
        string memory _image,  //Image of the Product
        string memory _name,   //Name of the Product
        string memory _size,   //Size of the Kloth, can be size in number or in S, M, L, XL, XXL
        uint _price,           //Price of the product
        uint _stock            //Available Stock
    ) public onlyOwner {
        require(bytes(_image).length > 0, "Image is required");
        require(bytes(_name).length > 0, "Name is required");
        require(bytes(_size).length > 0, "Size is required");
        require(_price > 0, "Price must be greater than 0");
        require(_stock > 0, "Stock must be greater than 0");
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

    //Get product function
    function getProduct(uint _index) public view
        returns (
            KlothType,     
            string memory,
            string memory,
            string memory,
            uint,
            uint,
            uint
        )
    {
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

    //Indexing of KlothTypes
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

    //Purchase Product Function
    function purchaseProduct(uint _index, uint _quantity) public payable {
        require(_index < productsLength, "Invalid product index");   //checks if the product being purchased is valid
        require(_quantity > 0, "Quantity must be greater than 0");   //checks if Qquantity is greater than 0
        require(_quantity <= products[_index].stock, "Insufficient stock"); //Checks if there is enough stock

        //calculation of total Price and Checks if the customer can afford
        uint totalPrice = products[_index].price * _quantity;
        require(msg.value >= totalPrice, "Insufficient funds");

        //Transfer tokens to Shop owner
        require(
            IERC20Token(CeloTokenAddress).transferFrom(msg.sender, owner, totalPrice),
          "Transfer failed."
        );

        // Update product quantity and stock
        products[_index].quantity += _quantity;
        products[_index].stock -= _quantity;

        emit ProductPurchased(msg.sender, _index, _quantity, totalPrice);
    }

    //Number of products in the contract
    function getProductsLength() public view returns (uint) {
        return productsLength;
    }
}
