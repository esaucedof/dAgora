var accounts;
var account;
var balance;

function setStatus(message, type="info") {
  var status = document.getElementById("status");
  $("#status").removeClass (function (index, css) {
    return (css.match (/(^|\s)alert-\S+/g) || []).join(' ');
  }).addClass("alert-" + type);
  status.innerHTML = message;
};

function setAddress() {
  document.getElementById("c_address").innerHTML = dAgora.deployed_address;
  document.getElementById("c_balance").innerHTML = web3.fromWei(web3.eth.getBalance(dAgora.deployed_address), "ether").toFixed(5);
}

function refreshBalances() {
  document.getElementById("cb_balance").innerHTML = web3.fromWei(web3.eth.getBalance(web3.eth.coinbase), "ether").toFixed(5)+ " ETH";
};

function listProducts() {
  var da = dAgora.deployed();
  da.productCount.call().then(function (result) {
    var counter = parseInt(result);
    console.log(counter);
    for(i = 0; i <= result; i++) {
      // Display product list
      da.productList.call(i).then(function(product) {
        $("#products").append("<h3>Product " + i + "</h3><p>Price: &Xi; "+product[1]+"</p>");
      }).catch(function(e) {
        console.error(e);
      });
    }
  }).catch(function(e) {
    console.error(e);
  });
}

function addProduct() {
  var da = dAgora.deployed();
  var price = web3.toWei(parseFloat(document.getElementById("price").value), "ether");
  var stock = parseFloat(document.getElementById("stock").value);

  setStatus("Initiating transaction... (please wait)");
  da.addProduct(price, stock, {from: web3.eth.coinbase}).then(function (tx_id) {
    console.log(tx_id);
    setStatus("Product added successfully", "success");
  }).catch(function (e) {
    console.log(e);
    setStatus("Error adding product: " + e, "danger");
  });
}

function withdraw() {

}

window.onload = function() {
  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      alert("There was an error fetching your accounts.");
      return;
    }

    if (accs.length == 0) {
      alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }

    accounts = accs;
    account = accounts[0];

    if(document.getElementById("c_address") !== null) setAddress();
    if(document.getElementById("products") !== null) listProducts();
    refreshBalances();
  });

  web3.eth.getTransactionReceiptMined = function (txnHash, interval) {
    var transactionReceiptAsync;
    interval |= 500;
    transactionReceiptAsync = function(txnHash, resolve, reject) {
        try {
            var receipt = web3.eth.getTransactionReceipt(txnHash);
            if (receipt == null) {
                setTimeout(function () {
                    transactionReceiptAsync(txnHash, resolve, reject);
                }, interval);
            } else {
                resolve(receipt);
            }
        } catch(e) {
            reject(e);
        }
    };

    return new Promise(function (resolve, reject) {
        transactionReceiptAsync(txnHash, resolve, reject);
    });
  };
}
