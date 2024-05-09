// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Admin, MatchConfig, MatchPlayerByAddress } from "../codegen/index.sol";

function isAdmin(bytes32 key) view returns (bool) {
  return Admin.get(key);
}

function min(int32 a, int32 b) pure returns (int32) {
  return a < b ? a : b;
}

function max(int32 a, int32 b) pure returns (int32) {
  return a > b ? a : b;
}

function addressToEntity(address a) pure returns (bytes32) {
  return bytes32(uint256(uint160((a))));
}

function entityToAddress(bytes32 value) pure returns (address) {
  return address(uint160(uint256(value)));
}

function entityToKeyTuple(bytes32 matchEntity, bytes32 entity) pure returns (bytes32[] memory keyTuple) {
  keyTuple = new bytes32[](2);
  keyTuple[0] = matchEntity;
  keyTuple[1] = entity;
}

function playerFromAddress(bytes32 matchEntity, address playerAddress) view returns (bytes32) {
  return MatchPlayerByAddress.get(matchEntity, playerAddress);
}

function manhattan(uint x0, uint y0, uint x1, uint y1) pure returns (uint) {
  uint dx = x0 > x1 ? x0 - x1 : x1 - x0;
  uint dy = y0 > y1 ? y0 - y1 : y1 - y0;
  return dx + dy;
}

function matchHasStarted(bytes32 matchEntity) view returns (bool) {
  uint256 startTime = MatchConfig.getStartTime(matchEntity);
  return startTime != 0 && startTime <= block.timestamp;
}
