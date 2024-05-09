// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MatchArrangement, MatchPlayers, MatchPlayer, MatchPlayerByAddress } from "../codegen/index.sol";

import { addressToEntity, manhattan } from "../libraries/LibUtils.sol";
import { createMatchEntity } from "../libraries/LibMatch.sol";
import { ARRANGEMENT_SIZE, ARRANGEMENT_SIDE_SIZE } from "../libraries/constants.sol";

function createPlayerEntity(bytes32 matchEntity, address playerAddress) returns (bytes32) {
  bytes32 addressEntity = addressToEntity(playerAddress);
  bytes32 playerEntity = createMatchEntity(matchEntity);

  uint32 index = uint32(MatchPlayers.length(matchEntity));
  require(index < 2, "players must be at most 2");
  MatchPlayers.push(matchEntity, playerEntity);
  MatchPlayer.set(matchEntity, playerEntity, index, playerAddress);
  MatchPlayerByAddress.set(matchEntity, playerAddress, playerEntity);

  return playerEntity;
}

function playerIndex(bytes32 matchEntity, bytes32 playerEntity) returns (uint32) {
  return MatchPlayer.getIndex(matchEntity, playerEntity);
}

function hasPiece(bytes32 matchEntity, bytes32 playerEntity, uint32 position) returns (bool) {
  return MatchArrangement.getItemArrangement(matchEntity, playerEntity, position) == 1;
}

function setPiece(bytes32 matchEntity, bytes32 playerEntity, uint32 position, bool present) {
  MatchArrangement.updateArrangement(matchEntity, playerEntity, position, present ? 1 : 0);
}

function otherSidePosition(uint position) returns (uint) {
  return ARRANGEMENT_SIZE - 1 - position;
}

function checkMove(
  uint x0,
  uint y0,
  uint x1,
  uint y1,
  uint32[] memory arrangement,
  uint32[] memory arrangementOtherSide
) {
  require(x0 == x1 || y0 == y1, "invalid move");
  require(manhattan(x0, y0, x1, y1) > 0, "invalid move");

  uint8[2][8] memory lakePositions = [[2, 5], [3, 5], [6, 5], [7, 5], [2, 4], [3, 4], [6, 4], [7, 4]];

  if (x0 == x1) {
    uint yMin = y0 < y1 ? y0 : y1;
    uint yMax = y0 > y1 ? y0 : y1;
    for (uint y = yMin + 1; y < yMax; y++) {
      uint position = x0 * ARRANGEMENT_SIDE_SIZE + y;
      require(arrangement[position] == 0, "piece in the way");
      require(arrangementOtherSide[otherSidePosition(position)] == 0, "piece in the way");
      for (uint i = 0; i < lakePositions.length; i++) {
        require(!(uint(lakePositions[i][0]) == x0 && uint(lakePositions[i][1]) == y), "lake in the way");
      }
    }
  } else {
    uint xMin = x0 < x1 ? x0 : x1;
    uint xMax = x0 > x1 ? x0 : x1;
    for (uint x = xMin + 1; x < xMax; x++) {
      uint position = x * ARRANGEMENT_SIDE_SIZE + y0;
      require(arrangement[position] == 0, "piece in the way");
      require(arrangementOtherSide[otherSidePosition(position)] == 0, "piece in the way");
      for (uint i = 0; i < lakePositions.length; i++) {
        require(!(uint(lakePositions[i][0]) == x && uint(lakePositions[i][1]) == y0), "lake in the way");
      }
    }
  }
}
