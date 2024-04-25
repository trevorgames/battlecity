pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";

template PieceComparator() {
    signal input attacker;
    signal input defender;
    signal output out; // 0 -> failure; 1 -> success; 2 -> perish together

    var Marshal = 10;
    var General = 9;
    var Colonels = 8;
    var Major = 7;
    var Captain = 6;
    var Lieutenant = 5;
    var Sergeant = 4;
    var Miner = 3;
    var Scout = 2;
    var Spy = 1;
    var Bomb = 11;
    var Flag = 12;

    assert(attacker != Bomb && attacker != Flag);

    /*
      if (attacker == defender) {
          out = 2;
      } else if (defender == Flag) {
          out = 1;
      } else if (defender == Bomb) {
          if (attacker == Miner) {
              out = 1;
          } else {
              out = 0;
          }
      } else if (attacker == Spy && defender == Marshal) {
          out = 1;
      } else if (attacker > defender) {
          out = 1;
      } else {
          out = 0;
      }
    */

    component gtAD = GreaterThan(4);
    gtAD.in[0] <== attacker;
    gtAD.in[1] <== defender;

    component eqDM = IsEqual();
    eqDM.in[0] <== defender;
    eqDM.in[1] <== Marshal;

    component eqAS = IsEqual();
    eqAS.in[0] <== attacker;
    eqAS.in[1] <== Spy;

    component eqAM = IsEqual();
    eqAM.in[0] <== attacker;
    eqAM.in[1] <== Miner;

    component eqDB = IsEqual();
    eqDB.in[0] <== defender;
    eqDB.in[1] <== Bomb;

    component eqDF = IsEqual();
    eqDF.in[0] <== defender;
    eqDF.in[1] <== Flag;

    component eqAD = IsEqual();
    eqAD.in[0] <== attacker;
    eqAD.in[1] <== defender;

    signal andEqASEqDM;
    andEqASEqDM <== eqAS.out * eqDM.out;

    signal gtADout;
    gtADout <== gtAD.out * 1 + (1 - gtAD.out) * 0;

    signal andEqASEqDMout;
    andEqASEqDMout <== andEqASEqDM * 1 + (1 - andEqASEqDM) * gtADout;

    signal eqAMout;
    eqAMout <== eqAM.out * 1 + (1 - eqAM.out) * 0;

    signal neDBout;
    neDBout <== (1 - eqDB.out) * andEqASEqDMout;

    signal eqDBout;
    eqDBout <== eqDB.out * eqAMout + neDBout;

    signal eqDFout;
    eqDFout <== eqDF.out * 1 + (1 - eqDF.out) * eqDBout;

    out <== eqAD.out * 2 + (1 - eqAD.out) * eqDFout; 
}
