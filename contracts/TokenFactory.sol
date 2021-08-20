//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract TokenFactory {
    Token[] public tknArray;

    function deployToken(
        string memory name_,
        string memory symbol_,
        uint256 decimal_,
        uint256 cappedSupply_
    ) public returns (address) {
        Token tkn = new Token(
            name_,
            symbol_,
            decimal_,
            cappedSupply_,
            address(this)
        );
        tknArray.push(tkn);
        return address(tkn);
    }

    function pauseToken(address tokenAddress) public {
        uint256 i = 0;
        Token tkn;
        for (i; i < tknArray.length; i++) {
            if (address(tknArray[i]) == tokenAddress) {
                tkn = tknArray[i];
            }
        }
        tkn.pause();
    }

    function totalSuppy() public view returns (uint256) {
        uint256 i = 0;
        uint256 totalSuppy_ = 0;
        for (i; i < tknArray.length; i++) {
            totalSuppy_ += tknArray[i].totalSupply();
        }
        return totalSuppy_;
    }
}
