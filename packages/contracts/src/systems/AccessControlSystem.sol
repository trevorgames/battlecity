// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { MatchAllowed, MatchConfig } from "../codegen/index.sol";
import { MatchAccessControlType } from "../codegen/common.sol";
import { addressToEntity } from "../libraries/LibUtils.sol";
import { hasSeasonPass } from "../libraries/hasToken.sol";

contract AccessControlSystem is System {
  /**
   * Check if the account is allowed to join the match.
   */
  function isAllowed(bytes32 matchEntity, address account) public view returns (bool) {
    MatchAccessControlType accessControl = MatchConfig.getAccessControl(matchEntity);
    if (accessControl == MatchAccessControlType.AllowList) {
      return MatchAllowed.get(matchEntity, account);
    } else if (accessControl == MatchAccessControlType.SeasonPassOnly) {
      return hasSeasonPass(account);
    } else {
      return false;
    }
  }

  /**
   * Set the allow list of the match.
   */
  function setAllowList(bytes32 matchEntity, address[] memory accounts) public {
    require(
      MatchConfig.getAccessControl(matchEntity) == MatchAccessControlType.AllowList,
      "Access control is not AllowList"
    );

    bytes32 entity = addressToEntity(_msgSender());
    bytes32 createdBy = MatchConfig.getCreatedBy(matchEntity);
    require(entity == createdBy, "Caller is not match creator");

    for (uint256 i; i < accounts.length; i++) {
      MatchAllowed.set(matchEntity, accounts[i], true);
    }
  }
}
