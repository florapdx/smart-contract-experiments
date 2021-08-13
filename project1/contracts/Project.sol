//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Project {

  address public creator;
  string public name;
  uint public goal;
  uint public startTime;
  uint public endTime;
  uint public minContribution;
  uint public totalContributions = 0;
  uint public fundedAt = 0; // not funded yet
  uint public cancelledAt = 0; // not cancelled

  mapping(address => uint) public contributions;

  event ProjectContributionReceived(
    address projectAddress,
    address contributorAddress,
    uint contributionAmount
  );

  event ProjectFunded(
    address projectAddress,
    uint fundedAt
  );

  event ProjectFailed(
    address projectAddress
  );

  event ProjectCancelled(
    address projectAddress,
    uint cancelledAt
  );

  modifier isCreator() {
    msg.sender == creator;
    _;
  }

  modifier isActive() {
    (endTime > block.timestamp) && (fundedAt + cancelledAt == 0);
    _;
  }

  constructor(
    address creatorAddress,
    string memory projectName,
    uint goalAmount,
    uint projectStartTime,
    uint projectEndTime,
    uint fundingMin
  ) {
    creator = creatorAddress;
    name = projectName;
    goal = goalAmount;
    minContribution = fundingMin;
    startTime = projectStartTime;
    endTime = projectEndTime;
  }

  function makeContribution() external payable isActive {
    require(msg.value >= minContribution);
    uint _newTotal = totalContributions += msg.value;
    uint _contributionAmount = msg.value;

    // If this is the last contribution to reach the goal, remit any value
    // in excess of the goal back to the user; log their contribution less
    // any excess
    if (_newTotal > goal) {
      uint _excess = _newTotal - goal;
      _remitExcess(msg.sender, _excess);
      _newTotal -= _excess;
      _contributionAmount -= _excess;
    }
    totalContributions = _newTotal;
    contributions[msg.sender] += _contributionAmount;

    emit ProjectContributionReceived(address(this), msg.sender, _contributionAmount);
    _checkFundedStatus();
  }

  function _remitExcess(address contributor, uint amt) private {
    (bool success, ) = payable(contributor).call{value: amt}("");
    require(success, "Remit excess funds failed!");
  }

  function _checkFundedStatus() private {
    if (totalContributions >= goal) {
      fundedAt = block.timestamp;
      emit ProjectFunded(address(this), fundedAt);
    } else if (endTime <= block.timestamp) {
      emit ProjectFailed(address(this));
    }
  }

  function cancelProject() external isCreator {
    cancelledAt = block.timestamp;
    emit ProjectCancelled(address(this), cancelledAt);
  }

  function claimRefund() external {
    uint _contributionAmt = contributions[msg.sender];
    require(_contributionAmt > 0);
    require(address(this).balance >= _contributionAmt);

    // prevent reentrancy by zeroing-out balance before making transfer
    contributions[msg.sender] = 0;
    (bool success, ) = payable(msg.sender).call{value: _contributionAmt}("");
    require(success, "Refund failed");
  }

  function withdrawFunds(uint amount) external isCreator {
    require(fundedAt > 0);
    require(address(this).balance >= amount);
    // My (weak) understanding is that reentrancy attacks won't work
    // on address(this).balance (ie, at protocol layer), but not sure?
    // Is there an additional guard required here to prevent such attacks?
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Withdrawal failed");
  }
}
