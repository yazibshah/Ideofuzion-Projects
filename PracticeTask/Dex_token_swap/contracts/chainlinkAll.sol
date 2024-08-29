// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./PriceProvider.sol";

error TypeNotMatched();
error TokenTransferFailed(address token, address from, address to, uint256 amount);
error InvestmentBelowMinimum(uint256 investmentAmount);

contract TokenSwap is Ownable {
    IERC20 public ideoA;
    IERC20 public ideoB;
    PriceProvider public priceProvider;

    // Minimum investment in USD (scaled to 18 decimals)
    uint256 public constant MIN_INVESTMENT_USD = 2 * (10**18); // $20 scaled to 18 decimals
    uint256 priceInUSD_IdeoA = 2e18; // $2 per Token A, scaled to 18 decimals
    uint256 priceInUSD_IdeoB = 300e18; // $300 per Token B, scaled to 18 decimals

    enum SwapType { A, B }

    constructor(
        address _IdeoA, 
        address _IdeoB, 
        address _priceProvider 
    ) Ownable(msg.sender) {
        ideoA = IERC20(_IdeoA);
        ideoB = IERC20(_IdeoB);
        priceProvider = PriceProvider(_priceProvider);
    }

    // Function to get the latest price
    function getLatestPrice(address priceAddress) public view returns (uint256) {
        return priceProvider.getLatestPrice(priceAddress);
    }

    // Convert Token A and B amount
    function convertAB(uint256 amount, SwapType swapType, address priceAddress) public view returns (uint256) {
        uint256 buyingTokenPrice = priceProvider.getLatestPrice(priceAddress);
        if (swapType == SwapType.A) {
            // Convert amount of Token A to equivalent amount of Token B
            uint256 amountA = (amount * priceInUSD_IdeoA) / buyingTokenPrice;
            return amountA;
        } else {
            // Convert amount of Token B to equivalent amount of Token A
            uint256 amountB = ((amount * priceInUSD_IdeoB) / buyingTokenPrice) * (10**10);
            return amountB;
        }
    }

    // Swap function to handle the token swap logic
    function swap(SwapType swapType, address priceAddress, address paymentToken, uint256 amount,uint256 tokenABAmount) external payable {
        uint256 investmentInUSD;
        uint256 convertedAmount;

        // If paymentToken is address(0), it means user is sending BNB
        if (paymentToken == address(0)) {
            investmentInUSD = (msg.value * priceProvider.getLatestPrice(priceAddress)) / 1e18;
        } else {
            // Calculate the USD equivalent of the ERC20 token sent by the user
            uint256 tokenDecimals = IERC20Metadata(paymentToken).decimals();
            uint256 tokenPrice = priceProvider.getLatestPrice(priceAddress);
            investmentInUSD = (amount * tokenPrice) / (10**tokenDecimals);
            
            // Transfer the ERC20 token from the user to the contract
            IERC20(paymentToken).transferFrom(msg.sender, address(this), investmentInUSD);
        }

        // Calculate the converted amount based on the swap type
        convertedAmount = convertAB(tokenABAmount, swapType, priceAddress);

        // Enforce minimum investment check
        if (investmentInUSD < MIN_INVESTMENT_USD) {
            revert InvestmentBelowMinimum(investmentInUSD);
        }

        if (swapType == SwapType.A) {
            // Transfer Token A to the user
            require(investmentInUSD >= convertedAmount, "Amount is not enough");
            bool success = ideoA.transfer(msg.sender, tokenABAmount);
            if (!success) {
                revert TokenTransferFailed(address(ideoA), address(this), msg.sender, amount);
            }
        } else {
            // Transfer Token B to the user
            require(investmentInUSD >= convertedAmount, "Amount is not enough");
            bool success = ideoB.transfer(msg.sender, tokenABAmount);
            if (!success) {
                revert TokenTransferFailed(address(ideoB), address(this), msg.sender, amount);
            }
        }
    }

    function ProvideAllownce(address tokenAddress, address to , uint256 amount) external {
        IERC20(tokenAddress).approve(to, amount);
    }

    function transferToken(address tokenAddress, address to , uint256 value) external {
        IERC20(tokenAddress).transfer(to, value);
    }

    // Function to withdraw collected BNB from the contract
    function withdrawBNB(address _address, uint256 _amount) external onlyOwner returns (bool) {
        (bool success, ) = payable(_address).call{value: _amount}("");
        return success;
    }

    function getTokenABalance() external view onlyOwner returns (uint256) {
        return ideoA.balanceOf(address(this));
    }

    function getTokenBBalance() external view onlyOwner returns (uint256) {
        return ideoB.balanceOf(address(this));
    }

    // Withdraw function for Token A
    function withdrawTokenA(uint256 amount, address to) external onlyOwner {
        uint256 contractBalance = ideoA.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient Token A balance in contract");
        bool success = ideoA.transfer(to, amount);
        if (!success) {
            revert TokenTransferFailed(address(ideoA), address(this), to, amount);
        }
    }

    // Withdraw function for Token B
    function withdrawTokenB(uint256 amount, address to) external onlyOwner {
        uint256 contractBalance = ideoB.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient Token B balance in contract");
        bool success = ideoB.transfer(to, amount);
        if (!success) {
            revert TokenTransferFailed(address(ideoB), address(this), to, amount);
        }
    }
}
