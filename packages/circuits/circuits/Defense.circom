pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "QuinSelector.circom";
include "ArrangementHasher.circom";
include "PieceComparator.circom";

template Defense() {
    signal input lastArrangement[100]; // last arrangement
    signal input lastArrangementHash; // hash of last arrangement 
    signal input x; // x coordinate of the piece
    signal input y; // y coordinate of the piece
    signal input attackerPieceCode; // attacker piece code
    signal output pieceCode; // defender piece code
    signal output arrangementHash; // hash of new arrangement

    // check last arrangement
    component hasher = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasher.arrangement[i] <== lastArrangement[i];
    }
    hasher.out === lastArrangementHash;

    signal index;
    index <== y * 10 + x;
 
    // get piece code
    component quinSelector = QuinSelector(100, 7);
    for (var i = 0; i < 100; i++) {
        quinSelector.in[i] <== lastArrangement[i];
    }
    quinSelector.index <== index; 
    pieceCode <== quinSelector.out;

    // attacker vs defender
    component cmp = PieceComparator();
    cmp.attacker <== attackerPieceCode;
    cmp.defender <== pieceCode;

    // is equal to 0 (attacker failure)
    component eq = IsEqual();
    eq.in[0] <== cmp.out;
    eq.in[1] <== 0; // attacker failure

    // new piece code after comparison
    signal code;
    code <== eq.out * pieceCode + (1 - eq.out) * 0; // 0 represents no piece

    // new arrangement 
    signal arrangement[100];

    // assign new piece code
    component eqs[100];
    signal nesArrangement[100];
    for (var i = 0; i < 100; i++) { 
        eqs[i] = IsEqual();
        eqs[i].in[0] <== i;
        eqs[i].in[1] <== index;

        nesArrangement[i] <== (1 - eqs[i].out) * lastArrangement[i];
        arrangement[i] <== eqs[i].out * code + nesArrangement[i];
    }

    // compute hash of new arrangement
    component hasherNew = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasherNew.arrangement[i] <== arrangement[i];
    }
    
    arrangementHash <== hasherNew.out;
}

component main {public [lastArrangementHash, x, y, attackerPieceCode]}  = Defense();
