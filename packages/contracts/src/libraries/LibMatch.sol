// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MatchEntityCounter } from "../codegen/index.sol";

function createMatchEntity(bytes32 matchEntity) returns (bytes32 entity) {
  uint32 entityIndex = MatchEntityCounter.get(matchEntity) + 1;
  MatchEntityCounter.set(matchEntity, entityIndex);
  entity = bytes32(uint256(entityIndex));
  return entity;
}
