pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "QuinSelector.circom";
include "ArrangementHasher.circom";

template Attack() {
    signal input lastArrangement[100]; // last arrangement
    signal input lastArrangementHash; // hash of last arrangement 
    signal input lastX; // last x coordinate of the piece
    signal input lastY; // last y coordinate of the piece
    signal input x; // new x coordinate of the piece
    signal input y; // new y coordinate of the piece
    signal output pieceCode; // piece code
    signal output arrangementHashSuccess; // hash of new arrangement if success
    signal output arrangementHashFailure; // hash of new arrangement if failure

    // check last arrangement
    component hasher = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasher.arrangement[i] <== lastArrangement[i];
    }
    hasher.out === lastArrangementHash;

    signal lastIndex;
    signal index;

    lastIndex <== lastY * 10 + lastX;
    index <== y * 10 + x;

    // get piece code
    component quinSelector = QuinSelector(100, 7);
    for (var i = 0; i < 100; i++) {
        quinSelector.in[i] <== lastArrangement[i];
    }
    quinSelector.index <== lastIndex; 
    pieceCode <== quinSelector.out;

    // pieceCode !== 0, since 0 represents no piece
    component isz = IsZero();
    isz.in <== pieceCode;
    isz.out === 0;

    // new arrangement 
    signal arrangementSuccess[100];
    signal arrangementFailure[100];

    // assign new piece code
    component eqs[100];
    component eqsNew[100];
    signal eqsNeither[100];
    signal eqsNeitherArrangement[100];
    for (var i = 0; i < 100; i++) { 
        eqs[i] = IsEqual();
        eqs[i].in[0] <== i;
        eqs[i].in[1] <== lastIndex;

        eqsNew[i] = IsEqual();
        eqsNew[i].in[0] <== i;
        eqsNew[i].in[1] <== index;

        eqsNeither[i] <== (1 - eqs[i].out) * (1 - eqsNew[i].out);
        eqsNeitherArrangement[i] <== eqsNeither[i] * lastArrangement[i];
        // 0 represents no piece
        arrangementSuccess[i] <== eqs[i].out * 0 + eqsNew[i].out * pieceCode + eqsNeitherArrangement[i];
        arrangementFailure[i] <== eqs[i].out * 0 + (1 - eqs[i].out) * lastArrangement[i];
    }

    // compute hash of new arrangement
    component hasherSuccess = ArrangementHasher();
    component hasherFailure = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasherSuccess.arrangement[i] <== arrangementSuccess[i];
        hasherFailure.arrangement[i] <== arrangementFailure[i];
    }
    
    arrangementHashSuccess <== hasherSuccess.out;
    arrangementHashFailure <== hasherFailure.out;
}

component main {public [lastArrangementHash, lastX, lastY, x, y]}  = Attack();
