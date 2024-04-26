pragma circom 2.0.0;

include "ValueCounter.circom";
include "ArrangementHasher.circom";

/*
  Board arrangement, coordinates (x,y) of squares:
    (0,9), (1,9), (2,9), ..., (9,9)
    (0,8), (1,8), (2,8), ..., (9,8)
    ...,
    (0,6), (1,6), (2,6), ..., (9,6)

    // {x,y} represents lake, which can't be moved in.
    (0,5), (1,5), {2,5}, {3,5}, (4,5), (5,5), {6,5}, {7,5}, (8,5), (9,5)
    (0,4), (1,4), {2,4}, {3,4}, (4,4), (5,4), {6,4}, {7,4}, (8,4), (9,4)

    (0,3), (1,3), (2,3), ..., (9,3)
    ...,
    (0,1), (1,1), (2,1), ..., (9,1)
    (0,0), (1,0), (2,0), ..., (9,0)

  Piece codes:
    Marshal: 10
    General: 9
    Colonels: 8 (x 2)
    Major: 7 (x 3)
    Captain: 6 (x 4)
    Lieutenant: 5 (x 4)
    Sergeant: 4 (x 4)
    Miner: 3 (x 5)
    Scout: 2 (x 8)
    Spy: 1
    Bomb: 11 (x 6)
    Flag: 12
*/

template Setup() {
    signal input arrangement[40]; // [y][x] -> <piece code>
    signal output arrangementHash; // hash of arrangement

    // piece code -> count
    // the first element is a placeholder
    var ncodes[13] = [0, 1, 8, 5, 4, 4, 4, 3, 2, 1, 1, 6, 1];

    component cnts[12];

    // check count of piece codes
    for (var i = 0; i < 12; i++) {
        cnts[i] = ValueCounter(40);

        cnts[i].value <== i + 1; // piece code

        for (var j = 0; j < 40; j++) {
            cnts[i].ins[j] <== arrangement[j];
        }

        cnts[i].out === ncodes[i+1];
    }

    component hasher = ArrangementHasher();

    for (var i = 0; i < 100; i++) {
        if (i < 40) {
            hasher.in[i] <== arrangement[i];
        } else {
            hasher.in[i] <== 0;
        }
    }

    arrangementHash <== hasher.out;
}

component main = Setup();
