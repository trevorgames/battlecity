pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimc.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template ArrangementHasher() {
    signal input in[100];
    signal output out;

    /*
    component hasher = MultiMiMC7(100, 91);

    hasher.k <== 0;

    for (var i = 0; i < 100; i++) {
        hasher.in[i] <== in[i];
    }

    out <== hasher.out;
    */

    component n2bs[100];
    signal bits[400];
    for (var i = 0; i < 100; i++) {
        n2bs[i] = Num2Bits(4);
        n2bs[i].in <== in[i];
        bits[i*4] <== n2bs[i].out[0];
        bits[i*4+1] <== n2bs[i].out[1];
        bits[i*4+2] <== n2bs[i].out[2];
        bits[i*4+3] <== n2bs[i].out[3];
    }

    component b2nL = Bits2Num(200);
    component b2nR = Bits2Num(200);
    for (var i = 0; i < 200; i++) {
        b2nL.in[i] <== bits[i];
        b2nR.in[i] <== bits[i+200];
    }

    component hasher = MultiMiMC7(2, 91);
    hasher.in[0] <== b2nL.out;
    hasher.in[1] <== b2nR.out;
    hasher.k <== 0;

    out <== hasher.out;
}
