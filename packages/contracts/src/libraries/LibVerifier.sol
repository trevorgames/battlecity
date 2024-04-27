// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface ISetupVerifier {
  function verifyProof(
    uint[2] calldata _pA,
    uint[2][2] calldata _pB,
    uint[2] calldata _pC,
    uint[1] calldata _pubSignals
  ) external view returns (bool);
}

interface IMoveVerifier {
  function verifyProof(
    uint[2] calldata _pA,
    uint[2][2] calldata _pB,
    uint[2] calldata _pC,
    uint[6] calldata _pubSignals
  ) external view returns (bool);
}

interface IAttackVerifier {
  function verifyProof(
    uint[2] calldata _pA,
    uint[2][2] calldata _pB,
    uint[2] calldata _pC,
    uint[8] calldata _pubSignals
  ) external view returns (bool);
}

interface IDefenseVerifier {
  function verifyProof(
    uint[2] calldata _pA,
    uint[2][2] calldata _pB,
    uint[2] calldata _pC,
    uint[6] calldata _pubSignals
  ) external view returns (bool);
}

struct SetupPubSignals {
  uint arrangementHash;
}

struct MovePubSignals {
  uint lastArrangementHash;
  uint lastX;
  uint lastY;
  uint x;
  uint y;
  uint arrangementHash;
}

struct AttackPubSignals {
  uint lastArrangementHash;
  uint lastX;
  uint lastY;
  uint x;
  uint y;
  uint pieceCode;
  uint arrangementHashSuccess;
  uint arrangementHashFailure;
}

struct DefensePubSignals {
  uint lastArrangementHash;
  uint x;
  uint y;
  uint attackerPieceCode;
  uint pieceCode;
  uint arrangementHash;
}
