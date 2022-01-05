//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/*
 * 500k total supply
 * 10% initial supply for given treasury account
 * 2% tax on every transfer that adds to treasury account
 * Flag (init false) that toggles the tax on/off, owner-only
 */
contract TomatoCoin is ERC20 {

    using SafeMath for uint256;

    uint256 public fixedSupply = 500000;
    address treasury;

    bool taxOnTransfer;

    constructor(address _treasuryAddress) ERC20("TOMATO COIN", "TOM"){
        treasury = _treasuryAddress;
        uint256 memory _treasuryAllocation = fixedSupply.div(10);
        _mint(_treasuryAddress, _treasuryAllocation);
        _mint(msg.sender, fixedSupply.sub(_treasuryAllocation));
    }

    function toggleTax() onlyOwner {
        taxOnTransfer = !taxOnTransfer;
    }

    // NOTE: The OpenZepplin docs say that `balances` is no longer writeable,
    // [see: https://docs.openzeppelin.com/contracts/4.x/erc20-supply]
    // so it seems we're forced to use `transfer` in the _beforeTransfer hook in
    // order to excise the tax on transfers -- yuck! This creates the
    // precondition for race conditions here that we need to guard against
    // (eg, don't end up in a loop by taxing transfers of the tax itself).
    // There must be a better way to do this, right?!
    //
    // @dev don't allow minting new tokens or burning tokens via transfer to/from
    // 0 addresses; make sure there's a nonzero value.
    // [See https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol#L324]
    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        require(from != 0 && to !== 0 && value > 0);

        uint256 _amount;
        if (taxOnTransfer && to != treasury) {
            _amount = value.mul(0.98);
            transfer(from, treasury, value.sub(_amount));
        } else {
            _amount = value;
        }
        super._beforeTokenTransfer(from, to, _amount);
    }
}

/*
 * Goal: raise 30k Ether via ICO
 * Should only be available to whitelisted private investors starting in
 * a phased "seed" round, w/max total limit of 15k ETH, max per-contribution
 * limit of 1500 ETH.
 * Next is "general" round, total limit 30k (cumulative w/seed), 1k ETH
 * individual limit.
 * Next is "open", no individual limit. At this point, contract should unlock
 * all ICO ERC20 tokens for all contributors: 5 tokens/1 ETH.
 * The owner should have the ability to pause+resume fundraising at any time,
 * as well as be able to move phases forwards (only) at will.
 */
contract TomatoCoinICO is TomatoCoin, Ownable {

    event Investment(
        address investor,
        uint amount
    )

    enum Phase {
        Seed, // 0
        General, // 1
        Open // 2
    }

    Phase public phase = Phase.Seed;

    uint private _maxSeedTotal = 15000 ether;
    uint private _maxSeedContribution = 1500 ether;
    uint private _maxGeneralTotal = 30000 ether;
    uint private _maxGeneralContribution = 1000 ether;

    address[] private _seedWhitelist;

    mapping(address => uint256) balances;

    // @notice: this method can only be called once, after which new seed
    // entrants must be added via the addToSeedWhitelist method (and only
    // up until the seed round closes).
    function setSeedWhitelist(address[] calldata _seedInvestors) external onlyOwner {
        _seedWhitelist = _seedInvestors;
    }

    function addToSeedWhitelist(address calldata _seedInvestor) external onlyOwner {
        require(phase == Phase.Seed);
        _seedWhitelist.push(_seedInvestor);
    }

    function nextPhase() external onlyOwner {
        require(uint(phase) < 2, "Already in final phase");
        phase = Phase(uint(phase) + 1);
    }

    function pauseFundraising() external onlyOwner {

    }

    function resumeFundraising() external onlyOwner {

    }

    function invest(address _investor, uint256 _amount) external payable {

    }
}
