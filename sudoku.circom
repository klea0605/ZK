include "../node_modules/circomlib/circuits/comparators.circom"

template inRange(bits)
{
    signal input cmpValue;
    
    signal input lowerBound;
    signal input upperBound;

    signal output result;

    component outLower <== LessEqThan(bits);
    outLower.in[0] <== cmpValue;
    outLower.in[1] <== lowerBound;

    component outUpper <== GreaterEqThan(bits);
    outUpper.in[0] <== upperBound;
    outUpper.in[1] <== cmpValue;

    result <== outLower.out * outUpper.out;
}

    //[assignment] hint: you will need to initialize your RangeProof components here
    component rangeProofPuzzle = inRange(32);
    rangeProofPuzzle.lowerBound <== 0;
    rangeProofPuzzle.upperBound <== 9;

    // Mislim da ne moze da se koristi isti template za razlicite ulaze jer valjda definisanje signal input-a moze smao jednom
    // zato imam dve instance RP-a
    component rangeProofSolution = inRange(32);
    rangeProofSolution.lowerBound <== 0;
    rangeProofSolution.upperBound <== 9;
    
    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {

            rangeProofPuzzle.cmpValue <== puzzle[i][j]; // proverava da li je puzzle[i][j] u segmentu [0, 9]

            rangeProofPuzzle.out === 1;  // ovo menja assert jer constraint mora biti ispostovan

            rangeProofSolution.cmpValue <== solution[i][j];
            rangeProof.out === 1;

            mul.a[i][j] <== puzzle[i][j];
            mul.b[i][j] <== solution[i][j];
        }
    }