pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "CalculateTotal.circom";

template ValueCounter(n) {
    signal input ins[n];
    signal input value;
    signal output out;

    component calcTotal = CalculateTotal(n);
    component eqs[n];

    for (var i = 0 ; i < n; i++) {
        eqs[i] = IsEqual();
        eqs[i].in[0] <== ins[i];
        eqs[i].in[1] <== value;

        calcTotal.in[i] <== eqs[i].out;
    }

    out <== calcTotal.out;
}
