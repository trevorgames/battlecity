// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Verifier, MatchArrangement, MatchTurn, MatchPlayers } from "../codegen/index.sol";
import { ISetupVerifier, IMoveVerifier, IAttackVerifier, IDefenseVerifier, SetupPubSignals, MovePubSignals, AttackPubSignals, DefensePubSignals } from "../libraries/LibVerifier.sol";
import { matchHasStarted, playerFromAddress } from "../libraries/LibUtils.sol";
import { playerIndex } from "../libraries/LibPlayer.sol";
import { ARRANGEMENT_SIZE, PLAYER_ARRANGEMENT_SIZE } from "../libraries/constants.sol";

contract MoveSystem is System {
  function _check(bytes32 matchEntity, bytes32 playerEntity) internal {
    require(matchHasStarted(matchEntity), "match has not started");
    require(playerFromAddress(matchEntity, _msgSender()) == playerEntity, "you are not the player");
  }

  function setup(
    bytes32 matchEntity,
    bytes32 playerEntity,
    uint[8] calldata proof,
    SetupPubSignals calldata pubSignals
  ) public {
    ISetupVerifier verifier = ISetupVerifier(Verifier.getSetupVerifier());
    require(
      verifier.verifyProof(
        [proof[0], proof[1]],
        [[proof[2], proof[3]], [proof[4], proof[5]]],
        [proof[6], proof[7]],
        [pubSignals.arrangementHash]
      ),
      "Invalid setup proof"
    );

    bytes32[] memory players = MatchPlayers.get(matchEntity);
    require(players.length == 2, "match must have 2 players");

    _check(matchEntity, playerEntity);

    require(MatchArrangement.getArrangementHash(matchEntity, playerEntity) == 0, "player has already setup");
    uint32[] memory arrangement = new uint32[](ARRANGEMENT_SIZE);
    // Set first PLAYER_ARRANGEMENT_SIZE positions to 1
    for (uint i = 0; i < PLAYER_ARRANGEMENT_SIZE; i++) {
      arrangement[i] = 1;
    }
    MatchArrangement.set(matchEntity, playerEntity, pubSignals.arrangementHash, arrangement);

    for (uint i = 0; i < players.length; i++) {
      if (players[i] == playerEntity) {
        continue;
      }
      if (MatchArrangement.getArrangementHash(matchEntity, players[i]) == 0) {
        // Other player has not setup yet
        return;
      }
    }

    MatchTurn.set(matchEntity, 0 /* setup is turn 0 */, 0, 0, block.timestamp);
  }

  function move(
    bytes32 matchEntity,
    bytes32 playerEntity,
    uint[8] calldata proof,
    MovePubSignals calldata pubSignals
  ) public {
    IMoveVerifier verifier = IMoveVerifier(Verifier.getMoveVerifier());
    require(
      verifier.verifyProof(
        [proof[0], proof[1]],
        [[proof[2], proof[3]], [proof[4], proof[5]]],
        [proof[6], proof[7]],
        [
          pubSignals.arrangementHash,
          pubSignals.lastArrangementHash,
          pubSignals.lastX,
          pubSignals.lastY,
          pubSignals.x,
          pubSignals.y
        ]
      ),
      "Invalid move proof"
    );

    _check(matchEntity, playerEntity);

    require(MatchTurn.getResolvedAt(matchEntity) > 0, "match has not setup");

    // Turn 1 -> player 0; turn 2 -> player 1; ...
    require(playerIndex(matchEntity, playerEntity) + (MatchTurn.getTurn(matchEntity) % 2) == 1, "not your turn");

    require(
      MatchArrangement.getArrangementHash(matchEntity, playerEntity) == pubSignals.lastArrangementHash,
      "invalid arrangement hash"
    );
  }

  function attack(
    bytes32 matchEntity,
    bytes32 playerEntity,
    uint[8] calldata proof,
    AttackPubSignals calldata pubSignals
  ) public {
    IAttackVerifier verifier = IAttackVerifier(Verifier.getAttackVerifier());
    require(
      verifier.verifyProof(
        [proof[0], proof[1]],
        [[proof[2], proof[3]], [proof[4], proof[5]]],
        [proof[6], proof[7]],
        [
          pubSignals.arrangementHashSuccess,
          pubSignals.arrangementHashFailure,
          pubSignals.lastArrangementHash,
          pubSignals.lastX,
          pubSignals.lastY,
          pubSignals.x,
          pubSignals.y,
          pubSignals.pieceCode
        ]
      ),
      "Invalid attack proof"
    );
  }

  function defense(
    bytes32 matchEntity,
    bytes32 playerEntity,
    uint[8] calldata proof,
    DefensePubSignals calldata pubSignals
  ) public {
    IDefenseVerifier verifier = IDefenseVerifier(Verifier.getDefenseVerifier());
    require(
      verifier.verifyProof(
        [proof[0], proof[1]],
        [[proof[2], proof[3]], [proof[4], proof[5]]],
        [proof[6], proof[7]],
        [
          pubSignals.pieceCode,
          pubSignals.arrangementHash,
          pubSignals.lastArrangementHash,
          pubSignals.x,
          pubSignals.y,
          pubSignals.attackerPieceCode
        ]
      ),
      "Invalid defense proof"
    );
  }

  function arbitrate(bytes32 matchEntity, bytes32 playerEntity) public {}
}
