//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Project.sol";

/**
 * This is a root contract that keeps track of individual `Project` contracts,
 * keeping a private registry of those projects, defining events and query
 * methods.
 **/
contract Crowdfundr {

  event ProjectCreated(
    address projectAddress,
    address creatorAddress,
    string projectName,
    uint goalAmount,
    uint startTime
  );

  uint fundingWindow = 30 days;
  uint minContribution = 0.01 ether;

  // We're going to keep this private instead of public as in the Zombies
  // example because our Project contract will be storage and we don't want
  // projects stored 2x on the blockchain (individually and as a group).
  Project[] private projects;

  function startProject(string calldata name, uint goal) external {
    require(goal >= minContribution);
    uint startTime = block.timestamp;
    uint endTime = startTime + fundingWindow;

    Project project = new Project(
      msg.sender,
      name,
      goal,
      startTime,
      endTime,
      minContribution
    );

    emit ProjectCreated(
      address(project),
      msg.sender,
      name,
      goal,
      startTime
    );
  }

  // Could also add query methods for all active, successful, and cancelled
  function getAllProjects() external view returns(Project[] memory) {
    return projects;
  }
}
