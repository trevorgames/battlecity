pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template ArrangementHasher() {
    signal input arrangement[100];
    signal output out;

    component hasher = MiMCSponge(100, 220, 1);

    hasher.k <== 0;

    for (var i = 0; i < 100; i++) {
        hasher.ins[i] <== arrangement[i];
    }

    out <== hasher.outs[0];
}
