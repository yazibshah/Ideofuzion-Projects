// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {PasskeyWallet} from "./Passkey.sol";
import {PasskeyWalletV1} from "./PasskeyV1.sol";

contract Factory  {


    TransparentUpgradeableProxy proxy;

    mapping(address user => address proxy) public UserProxyAddress;
    mapping(address user => address newProxy) public newUserProxyAddress;

    PasskeyWallet public conPasskey;
    PasskeyWalletV1 public conPasskeyAV1;


    constructor(){
        conPasskey = new PasskeyWallet();
        conPasskeyAV1= new PasskeyWalletV1();
    }


    // Deploy the proxy and initialize with a value
    function deployProxy(address owner) public returns (address) {

        // Deploy the TransparentUpgradeableProxy
        proxy = new TransparentUpgradeableProxy(
            address(conPasskey),   // Address of the deployed PasskeyWallet implementation
            address(owner),         // ProxyAdmin is the admin of this proxy
            abi.encodeWithSignature("initialize(address)", owner) 
        );

        UserProxyAddress[msg.sender]=address(proxy);
        return address(proxy);
        
    }

     function upgradeProxy()  public payable{
        PasskeyWallet(payable(address(proxy))).upgradeProxy(address(conPasskeyAV1));
        newUserProxyAddress[msg.sender]=address(proxy);
    } 


    


}
