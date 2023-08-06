// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Klothline Smart Contract
 * @dev This contract represents a smart contract for managing a clothing line store.
 * It allows the owner to add, update, and remove products, and customers can purchase products.
 * @notice This smart contract is based on the MIT license.
 */
contract klothline{
    uint internal productsLength = 0;
    address payable public owner;
    enum KlothType{none, pants, shirts, dresses, skirts, shorts, shoes, headwear}

    /** 
     * @dev Struct representing a product in the store.
     * @param klothtype The type of clothing (enum KlothType).
     * @param image The URL of the product image.
     * @param name The name of the product.
     * @param size The size of the product.
     * @param price The price of the product.
     * @param quantity The quantity of the product (not used in addproduct).
     * @param stock The available stock of the product.
     */
    struct product{
        KlothType klothtype;
        string image;
        string name;
        string size; 
        uint price;
        uint quantity;
        uint stock;
    }

    /** 
     * @dev Mapping to store the products, indexed by their unique IDs.
     */
    mapping (uint => product) internal products;

    /** 
     * @dev Contract constructor. Sets the contract owner to the deployer's address.
     */
    constructor() payable {
        owner = payable(msg.sender);
    }

    /** 
     * @dev Modifier that allows only the contract owner to perform certain functions.
     */
    modifier onlyOwner {
        require(owner == msg.sender, "only owner can perform this");
        _;
    }

    /** 
     * @dev Adds a new product to the store.
     * @param _klothtype The type of clothing (enum KlothType).
     * @param _image The URL of the product image.
     * @param _name The name of the product.
     * @param _size The size of the product.
     * @param _price The price of the product.
     * @param _stock The available stock of the product.
     */
    function addproduct(
        KlothType _klothtype,
        string memory _image,
        string memory _name,
        string memory _size,
        uint _price,
        uint _stock
    ) public onlyOwner {
        require(bytes(_image).length > 0, "Image is required");
        require(bytes(_name).length > 0, "Name is required");
        require(bytes(_size).length > 0, "Size is required");
        require(_price > 0, "Price must be greater than 0");
        require(_stock > 0, "Stock must be greater than 0");

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

    /** 
     * @dev Updates the details of an existing product in the store.
     * @param _index The index of the product to be updated.
     * @param _image The new URL of the product image.
     * @param _name The new name of the product.
     * @param _size The new size of the product.
     * @param _price The new price of the product.
     * @param _stock The new available stock of the product.
     */
    function updateProduct(
        uint _index,
        string memory _image,
        string memory _name,
        string memory _size,
        uint _price,
        uint _stock
    ) public onlyOwner {
        require(_index < productsLength, "Invalid product index");
        require(bytes(_image).length > 0, "Image is required");
        require(bytes(_name).length > 0, "Name is required");
        require(bytes(_size).length > 0, "Size is required");
        require(_price > 0, "Price must be greater than 0");
        require(_stock > 0, "Stock must be greater than 0");
    
        products[_index].image = _image;
        products[_index].name = _name;
        products[_index].size = _size;
        products[_index].price = _price;
        products[_index].stock = _stock;
    }


    /** 
     * @dev Removes an existing product from the store.
     * @param _index The index of the product to be removed.
     */
    function removeProduct(uint _index) public onlyOwner {
        require(_index < productsLength, "Invalid product index");

        // Move the last product to the position of the one to be deleted
        products[_index] = products[productsLength - 1];

        // Delete the last element (the duplicate)
        delete products[productsLength - 1];

        // Decrement the productsLength to reflect the removal
        productsLength--;
    }


    /** 
     * @dev Returns the details of a product.
     * @param _index The index of the product to retrieve details.
     * @return The product details as a tuple (klothtype, image, name, size, price, quantity, stock).
     */
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

    /** 
     * @dev Returns an array containing all the KlothType enum values.
     * @return An array of KlothType enum values.
     */
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

    /** 
     * @dev Allows customers to purchase a product from the store.
     * @param _index The index of the product to be purchased.
     */
    function purchaseproduct(uint _index)public payable{
        require(_index < productsLength, "Invalid product index");
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


    /** 
     * @dev Returns the total number of products in the store.
     * @return The total number of products.
     */
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }

}
