// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Verifier } from "../codegen/index.sol";
import { ISetupVerifier, IMoveVerifier, IAttackVerifier, IDefenseVerifier, SetupPubSignals, MovePubSignals, AttackPubSignals, DefensePubSignals } from "../libraries/LibVerifier.sol";

contract MoveSystem is System {
  function setup(
    bytes32 matchEntity,
    bytes32 entity,
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
  }

  function move(
    bytes32 matchEntity,
    bytes32 entity,
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
  }

  function attack(
    bytes32 matchEntity,
    bytes32 entity,
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
    bytes32 entity,
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
}
