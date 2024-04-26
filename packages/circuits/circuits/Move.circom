pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "QuinSelector.circom";
include "ArrangementHasher.circom";

template Move() {
    signal /* private */ input lastArrangement[100]; // last arrangement
    signal input lastArrangementHash; // hash of last arrangement 
    signal input lastX; // last x coordinate of the piece
    signal input lastY; // last y coordinate of the piece
    signal input x; // new x coordinate of the piece
    signal input y; // new y coordinate of the piece
    signal output arrangementHash; // hash of new arrangement

    // check last arrangement
    component hasher = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasher.in[i] <== lastArrangement[i];
    }
    hasher.out === lastArrangementHash;

    signal pieceCode;
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
    signal arrangement[100];

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
        arrangement[i] <== eqs[i].out * 0 + eqsNew[i].out * pieceCode + eqsNeitherArrangement[i];
    }

    // compute hash of new arrangement
    component hasherNew = ArrangementHasher();
    for (var i = 0; i < 100; i++) {
        hasherNew.in[i] <== arrangement[i];
    }
    
    arrangementHash <== hasherNew.out;
}

component main {public [lastArrangementHash, lastX, lastY, x, y]}  = Move();
