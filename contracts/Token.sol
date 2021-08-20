//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Token is ERC20, ERC20Capped, AccessControl, Pausable {
    bytes32 public constant minterRole = keccak256("minter"); //roles defined
    bytes32 public constant burnerRole = keccak256("burner");

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 decimal_,
        uint256 cappedSupply_,
        address admin_
    ) ERC20(name_, symbol_) ERC20Capped(cappedSupply_) Pausable() {
        decimals(decimal_);
        _setupRole(DEFAULT_ADMIN_ROLE, admin_);
        _setRoleAdmin(minterRole, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(burnerRole, DEFAULT_ADMIN_ROLE);
    }

    function addMinter(address newMinter)
        public
        onlyRole(getRoleAdmin(minterRole))
    {
        //owner should add minter
        grantRole(minterRole, newMinter);
    }

    function addBurner(address newBurner)
        public
        onlyRole(getRoleAdmin(burnerRole))
    {
        //owner should add burner
        grantRole(burnerRole, newBurner);
    }

    function decimals(uint256 _decimals) public pure returns (uint256) {
        return _decimals;
    }

    function mint(address account, uint256 amount)
        public
        onlyRole(minterRole)
        whenNotPaused
    {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount)
        internal
        override(ERC20Capped, ERC20)
    {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        //pauses all token operations
        _pause();
    }

    function balanceOf(address account)
        public
        view
        override
        whenNotPaused
        returns (uint256)
    {
        return super.balanceOf(account);
    }

    function totalSupply()
        public
        view
        override
        whenNotPaused
        returns (uint256)
    {
        return super.totalSupply();
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        //override for pause functionality
        super.transfer(recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        //override for pause functionality
        return super.transferFrom(sender, recipient, amount);
    }

    function burnFrom(address account, uint256 amount)
        public
        onlyRole(burnerRole)
        whenNotPaused
    {
        _burn(account, amount);
    }
}
