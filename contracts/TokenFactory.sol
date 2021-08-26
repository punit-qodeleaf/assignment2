//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenFactory is Ownable{
    uint256 public totalTokensDeployed = 0;
    mapping(uint256 => address) public tokenAddress;
    mapping(address => Token) public tokenDeployed;

    constructor() Ownable(){

    }

    function deployToken(
        string memory name_,
        string memory symbol_,
        uint8 decimal_,
        uint256 cappedSupply_
    ) public returns (address) {
        Token tkn = new Token(
            name_,
            symbol_,
            decimal_,
            cappedSupply_
        );
        ++totalTokensDeployed;
        tokenAddress[totalTokensDeployed] = address(tkn);
        tokenDeployed[address(tkn)] = tkn;
        return address(tkn);
    }

    function pauseToken(address tokenAddress_) public {
        tokenDeployed[tokenAddress_].pause();
    }

    function addMinterToToken(address tokenAddress_, address minter) public {
       tokenDeployed[tokenAddress_].addMinter(minter);
    }

    function addBurnerToToken(address tokenAddress_, address burner) public {
        tokenDeployed[tokenAddress_].addBurner(burner);
    }

    function totalSupply() public view returns (uint256) {
        uint256 totalSupply_ = 0;
        uint256 i = 0;
        for (i; i < totalTokensDeployed; i++) {
            Token tokenToCheck = tokenDeployed[tokenAddress[i+1]];
            if (!tokenToCheck.paused()) {
                totalSupply_ += tokenToCheck.totalSupply();
            }
        }
        return totalSupply_;
    }
}
