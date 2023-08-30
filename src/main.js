import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import klothlineAbi from '../Contract/klothline.abi.json'
import erc20Abi from "../contract/erc20.abi.json"




const ERC20_DECIMALS = 18
const klothlineAddress = "0xa369d914EC1Cd5D6b86F42eE1328665B298f0286"
const CeloContractAddress = "0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9"


let kit
let contract
let products = []






//connecting celo wallet to the dapp
const connectCeloWallet = async function () {
     if (window.celo) {
          try {
               notification("⚠️ Please approve this DApp to use it.")
               await window.celo.enable()
               notificationOff()
               const web3 = new Web3(window.celo)
               kit = newKitFromWeb3(web3)

               const accounts = await kit.web3.eth.getAccounts()
               kit.defaultAccount = accounts[0]

               contract = new kit.web3.eth.Contract(klothlineAbi, klothlineAddress)
          } catch (error) {
               notification(`⚠️ ${error}.`)
          }
     } else {
          notification("⚠️ Please install the CeloExtensionWallet.")
     }
}



//reading the balance of someones wallet
const getBalance = async function () {
     const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
     const CeloBalance = totalBalance.CELO.shiftedBy(-ERC20_DECIMALS).toFixed(2)
     document.querySelector("#balance").textContent = CeloBalance
}


//adding products
const addProducts = async function () {
     const _productsLength = await contract.methods.getProductsLength().call()
     const _products = []
     

     for (let i = 0; i < _productsLength; i++) {
          let _product = new Promise(async (resolve, reject) => {
               let p = await contract.methods.getProduct(i).call()
               resolve({
                    index: i,
                    klothtype: p[0],
                    image: p[1],
                    name: p[2],
                    size: p[3],
                    price: new BigNumber(p[4]),
                    stock: p[5],
                    quantity: p[6]
               })
          })
          _products.push(_product)
     }
     products = await Promise.all(_products)
     renderProducts()

}



async function approve(_price) {
     const CeloContract = new kit.web3.eth.Contract(erc20Abi, CeloContractAddress)

     const result = await CeloContract.methods
          .approve(klothlineAddress, _price)
          .send({ from: kit.defaultAccount })
     return result
}

async function populateKlothTypes() {
     const types = await contract.methods.getKlothTypes().call();
     const dropdownHtml = typedropdown(types);
     document.getElementById("klothtype").innerHTML = dropdownHtml;
}


//Calling cKlothTypes and putting them in a DropDown
function typedropdown(types) {
     return`
          <option value="0">Choose...</option>
          <option value=${types[0]}>Pants</option>
          <option value=${types[1]}>Shirts</option>
          <option value=${types[2]}>Dresses</option>
          <option value=${types[3]}>Skirts</option>
          <option value=${types[4]}>Shorts</option>
          <option value=${types[5]}>Shoes</option>
          <option value=${types[6]}>Headwear</option>
          `
                                   
}
   
 
          //Rendering Items to their specific Containers
function renderProducts() {
     const typeselected = document.getElementById("klothtype").value;
     document.getElementById("pants").innerHTML = ""
     document.getElementById("shirts").innerHTML = ""
     document.getElementById("dresses").innerHTML = ""
     document.getElementById("skirts").innerHTML = ""
     document.getElementById("shorts").innerHTML = ""
     document.getElementById("shoes").innerHTML = ""
     document.getElementById("headwear").innerHTML = ""



     products.forEach((_product) => {
          if (_product.klothtype === typeselected || typeselected === "0") {
               const newDiv = document.createElement("div")
               newDiv.className = "card"
               newDiv.innerHTML = productTemplate(_product)

               if (_product.klothtype === "1") {
                    document.getElementById("pants").appendChild(newDiv);

               } else if (_product.klothtype === "2") {
                    document.getElementById("shirts").appendChild(newDiv);

               } else if (_product.klothtype === "3") {
                    document.getElementById("dresses").appendChild(newDiv);

               } else if (_product.klothtype === "4") {
                    document.getElementById("skirts").appendChild(newDiv);

               } else if (_product.klothtype === "5") {
                    document.getElementById("shorts").appendChild(newDiv);

               } else if (_product.klothtype === "6") {
                    document.getElementById("shoes").appendChild(newDiv);

               } else if (_product.klothtype === "7") {
                    document.getElementById("headwear").appendChild(newDiv);

               }
          }
     })
}







     ///Added Product Template

function productTemplate(_product) {
     return `
          <img src=${_product.image} class="card-img-top">
          <div class="card-body ">
               <h5 class="card-title">${_product.name}</h5>
               <p class="card-text">Size: ${_product.size}</p>
               <p class="card-text">In Stock: ${_product.stock}</p>
               <p class="card-text">Price: ${_product.price.shiftedBy(-ERC20_DECIMALS).toFixed(2)} CELO</p> 
               <div class="input-group mb-3">
                    <span class="input-group-text">Qty:</span>
                    <input type="number" name="quantity" class="form-control" id="ProductQty" placeholder="0" value=${_product.quantity}/>
                    <button class="btn btn-secondary purchasebtn" id=${_product.index}>Buy</button>
               </div>
 
          </div>

     `
}



function notification(_text) {
     const modalContainer = document.querySelector(".modal-container");
     const notificationText = document.querySelector("#notification");
     notificationText.textContent = _text;
     modalContainer.style.display = "flex"; 
}
   
function notificationOff() {
     const modalContainer = document.querySelector(".modal-container");
     modalContainer.style.display = "none"; 
}


window.addEventListener("load", async () => {
     notification("⌛ Loading...")
     await connectCeloWallet()
     await populateKlothTypes()
     await getBalance()
     await addProducts()
     notificationOff()
});



     // Adding new Product
document.querySelector("#newProductBtn").addEventListener("click", async (e) => {
     const klothtype = document.getElementById("klothtype").value;
     const imageUrl = document.getElementById("imgmgUrl").value.trim();
     const name = document.getElementById("name").value.trim();
     const size = document.getElementById("size").value.trim();
     const price = new BigNumber(document.getElementById("newprice").value).shiftedBy(ERC20_DECIMALS);
     const stock = parseInt(document.getElementById("addedstock").value);


     if (klothtype === "0") {
          notification("⚠️ Please select a valid KlothType.");
          return;
     }

     if (!imageUrl) {
          notification("⚠️ Image URL is required.");
          return;
     }

     if (!name) {
          notification("⚠️ Product name is required.");
          return;
     }

     if (!size) {
          notification("⚠️ Product size is required.");
          return;
     }

     if (isNaN(price) || price.isLessThanOrEqualTo(0)) {
          notification("⚠️ Price must be a valid positive number.");
          return;
     }

     if (isNaN(stock) || stock <= 0) {
          notification("⚠️ Stock must be a valid positive integer.");
          return;
     }

     notification(`⌛ Adding "${name}"...`);
     try {
          const result = await contract.methods.addProduct(
               klothtype, 
               imageUrl, 
               name, 
               size, 
               price.toString(), 
               stock)
               .send({ from: kit.defaultAccount });
          console.log(result)
          notification(`🎉 You successfully added "${name}".`);
          document.getElementById("klothtype").value = "0";
          document.getElementById("imgmgUrl").value = "";
          document.getElementById("name").value = "";
          document.getElementById("size").value = "";
          document.getElementById("newprice").value = "";
          document.getElementById("addedstock").value = "";
          addProducts();
          populateKlothTypes();

     } catch (error) {
          notification(`⚠️ Failed to add product: ${error}.`);
     }

     notificationOff();
});
        




          /////////Buying function/////////
document.querySelector("#shopitems").addEventListener("click", async (e) => {
     
     if (e.target.className.includes("purchasebtn")) {
          const index = e.target.id;
          const quantity = document.getElementById("ProductQty").value
          const price = products[index].price
          const totalPrice = price * quantity
          
          notification("⌛ Waiting for payment approval...");
          try {
               await approve(totalPrice)
          } catch (error) {
               notification(`⚠️ ${error}.`)
          }
          

          try {
               const result = await contract.methods
                    .purchaseProduct(index, quantity)
                    .send({ from: kit.defaultAccount});

               console.log(result);

               notification(`🎉 You successfully bought "${products[index].name}".`);
               addProducts();
               getBalance(); 
          } catch (error) {
               notification(`⚠️ ${error}.`);
          }
          notificationOff()
     }
});






