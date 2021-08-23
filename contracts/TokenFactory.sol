//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract TokenFactory {
    uint256 public totalTokensDeployed;
    mapping(uint256 => address) public tokenAddress;
    mapping(address => Token) public tokenDeployed;
    Token recentToken;

    constructor() {
        totalTokensDeployed = 0;
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
            cappedSupply_,
            address(this)
        );
        ++totalTokensDeployed;
        tokenAddress[totalTokensDeployed] = address(tkn);
        tokenDeployed[address(tkn)] = tkn;
        return address(tkn);
    }

    function pauseToken(address tokenAddress_) public {
        Token tkn = tokenDeployed[tokenAddress_];
        tkn.pause();
    }

    function addMinterToToken(address tokenAddress_, address minter) public {
        Token tkn = tokenDeployed[tokenAddress_];
        tkn.addMinter(minter);
    }

    function addBurnerToToken(address tokenAddress_, address burner) public {
        Token tkn = tokenDeployed[tokenAddress_];
        tkn.addBurner(burner);
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
