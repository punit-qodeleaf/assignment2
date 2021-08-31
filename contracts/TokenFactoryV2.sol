//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TokenFactoryV2 is Initializable, OwnableUpgradeable{
    uint256 public totalTokensDeployed;
    mapping(uint256 => address) public tokenAddress;
    mapping(address => Token) public tokenDeployed;
    mapping(uint => Token) public tokenIndexing;
    
    event deployed(address indexed tknAddress, uint indexed tknIndex, string name, string symbol );

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
        emit deployed(address(tkn), totalTokensDeployed, name_, symbol_);
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
