// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import "./StableHype.sol";

interface Oracle { function latestAnswer() external view returns (uint); }

contract Manager {
  uint public constant MIN_COLLAT_RATIO = 1.5e18;

  ERC20 public immutable khype;
  HypeUSD public immutable hypeUSD;

  Oracle public immutable oracle;

  mapping(address => uint) public address2deposit;
  mapping(address => uint) public address2minted;

  constructor(address _khype, address _hypeUSD, address _oracle) {
    khype   = ERC20(_khype);
    hypeUSD  = HypeUSD(_hypeUSD);
    oracle = Oracle(_oracle);
  }

  function deposit(uint amount) public {
    khype.transferFrom(msg.sender, address(this), amount);
    address2deposit[msg.sender] += amount;
  }

  function burn(uint amount) public {
    address2minted[msg.sender] -= amount;
    hypeUSD.burn(msg.sender, amount);
  }

  function mint(uint amount) public {
    address2minted[msg.sender] += amount;
    require(collatRatio(msg.sender) >= MIN_COLLAT_RATIO);
    hypeUSD.mint(msg.sender, amount);
  }

  function withdraw(uint amount) public {
    address2deposit[msg.sender] -= amount;
    require(collatRatio(msg.sender) >= MIN_COLLAT_RATIO);
    khype.transfer(msg.sender, amount);
  }

  function liquidate(address user) public {
    require(collatRatio(user) < MIN_COLLAT_RATIO);
    hypeUSD.burn(msg.sender, address2minted[user]);
    khype.transfer(msg.sender, address2deposit[user]);
    address2deposit[user] = 0;
    address2minted[user] = 0;
  }

  function collatRatio(address user) public view returns (uint) {
    uint minted = address2minted[user];
    if (minted == 0) return type(uint256).max;
    uint256 totalValue = address2deposit[user] * (oracle.latestAnswer() * 1e10) / 1e18;
    return totalValue / minted;
  }
}