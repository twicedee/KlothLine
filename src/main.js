import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import klothlineAbi from '../Contract/klothline.abi.json'
//app.use(express.static('images'));


const ERC20_DECIMALS = 18
const klothlineAddress = "0xa46460c34254971a42B3Ba3400CCA66b6dE0Cf2f"


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
     const cUSDBalance = totalBalance.CELO.shiftedBy(-ERC20_DECIMALS).toFixed(2)
     document.querySelector("#balance").textContent = cUSDBalance
}






//adding products
const addProducts = async function () {
     const _productsLength = await contract.methods.getProductsLength().call()
     const _products = []
     

     for (let i = 0; i < _productsLength; i++) {
          let _product = new Promise(async (resolve, reject) => {
               let p = await contract.methods.readProduct(i).call()
               resolve({
                    index: i,
                    klothtype: p[0],
                    image: p[1],
                    name: p[2],
                    size: p[3],
                    price: new BigNumber(p[4]),
                    quantity: p[5],
                    stock: p[6]
               })
          })
          _products.push(_product)
     }
     products = await Promise.all(_products)
     renderProducts()

}




function typedropdown(types) {
     let dropdownOptions = "";
     for (let i = 0; i < types.length; i++) {
          dropdownOptions += `<option value="${i}">${types[i]}</option>`;
     }
     return dropdownOptions;
}

   
async function Kloth_Types() {
     const types = await contract.methods.getKlothTypes().call();
     const dropdownHtml = typedropdown(types);
     document.getElementById("klothtype").innerHTML = dropdownHtml;
}
   
 
//Create the input 


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

               } else if (_product.kloyhtype === "5") {
                    document.getElementById("shorts").appendChild(newDiv);

               } else if (_product.klothtype === "6") {
                    document.getElementById("shoes").appendChild(newDiv);

               } else if (_product.klothtype === "7") {
                    document.getElementById("headwear").appendChild(newDiv);

               }
          }
     })
}









function productTemplate(_product) {
     return `
          <img src=${_product.image} class="card-img-top">
          <div class="card-body">
               <h5 class="card-title">${_product.name}</h5>
               <p class="card-text">Size: ${_product.size}</p>
               <p class="card-text">In Stock: ${_product.stock}</p>
               <p class="card-text">Price: ${_product.price.shiftedBy(-ERC20_DECIMALS).toFixed(2)} CELO</p> 
               <p class="card-text">Qty: <input type="number" class="form-control mb-2" placeholder="0" value=${_product.quantity}/></p>
               <a class="btn btn-primary purchasebtn btn-rounded-pill" id=${_product.index}>Purchase</a>
               
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
     await Kloth_Types()
     await getBalance()
     await addProducts()
     notificationOff()
});




document.querySelector("#newProductBtn").addEventListener("click", async (e) => {
     const params = [
          document.getElementById("klothtype").value,
          document.getElementById("imgmgUrl").value,
          document.getElementById("name").value,
          document.getElementById("size").value,
          new BigNumber(document.getElementById("newprice").value).shiftedBy(ERC20_DECIMALS).toString(),
          document.getElementById("addedstock").value
     ] 
     
     notification(`⌛ Adding "${params[2]}"...`)
     try {
          const result = await contract.methods.addproduct(...params).send({ from: kit.defaultAccount })
          notification(`🎉 You successfully added "${params[2]}".`)
          
          document.getElementById("imgmgUrl").value = "";
          document.getElementById("name").value = "";
          document.getElementById("size").value = "";
          document.getElementById("newprice").value = "";
          document.getElementById("addedstock").value = "";
          addProducts()
          //populateKlothTypes()
          
     } catch (error) {
          notification(`⚠️ Failed to add product: ${error}.`);
          
     }

     notificationOff()
     
     
        
});



document.querySelector("#shopitems").addEventListener("click", async (e) => {
     if (e.target.className.includes("purchasebtn")) {
          const index = e.target.id;
          notification("⌛ Waiting for payment approval...");

          try {
               // Call the purchaseproduct function on the smart contract
               const result = await contract.methods
                    .purchaseproduct(index)
                    .send({ from: kit.defaultAccount});

               // Log the transaction details for testing
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






