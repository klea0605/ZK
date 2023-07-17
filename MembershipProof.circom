pragma circom  2.0.0;

include "./node_modules/circomlib/circuits/mux1.circom"
include "./node_modules/circomlib/circuits/poseidon.circom"

// nLeves <-> visina stabla
template MerkleTreeInclusionProof(nLevels)
{
    // Input-i: 
    // moramo da znamo:
    // od koje vrednosti krecemo
    signal input leaf;

    // koji je path do root-a 
    // (ovo su samo Bool vrednosti za odgovarajuci nivo)
    // ako je vrednost 0, znaci da koristimo sibling-a; ako je 1, znaci treba nam taj cvor
    signal input pathIndices[nLevels];

    // i koji su nam susedni hesevi (jer i njih koristimo)
    signal input siblings[nLevels];


    // Pomocno:
    // Komponente: JER POZIVAS TEMPLATE !!
    // multiplekser koji odredjuje ISPRAVAN redosled Poseidon(levo, desno)
    component mux[nLevels];
    // hesevi mog cvora i njegovog suseda koji omogucavaju penjanje uz drvo
    component poseidons[nLevels];
    // Na svakom koraku cuvamo heseve jer to jednoznacno odredjuje put
    signal hashes[nLevels+1];
    hashes[0] <== leaf;

    // Output: 
    signal output root;


    // Penjemo se uz stablo
    for(var i = 0; i < nLevels; i++)
    {
        // Assert da pathIndices mora da bude 0 ili 1
        pathIndices[i] * (pathIndices[i] - 1) === 0;

        // pozivanje template-a ide sa '='
        mux[i] = MultiMux1(2);
        mux[i].c[0][0] <== hashes[i];
        mux[i].c[0][1] <== siblings[i];
        mux[i].c[1][0] <== siblings[i];
        mux[i].c[1][1] <== hashes[i];

        // selekcija se vrsi na osnovu poretka levo/desno koji saznajemo bool oznakom iz PathIndices
        // pathIndices[i] = 0 <-> ovaj cvor (i) je levo od svog sibling-a u MerkleTree-u
        // pathIndices[i] = 1 <-> ovaj cvor (i) je desno od svog sibling-a u MerkleTree-u
        mux[i].s <== pathIndices[i];

        // Hesiramo tekuci nivo stabla
        poseidons[i] = Poseidon(2);
        poseidons[i].inputs[0] <== mux[i].out[0];
        poseidons[i].inputs[1] <== mux[i].out[1];

        // Da bih se popela do gornjeg cvora treba mi hes mog cvora i njegovog suseda
        hashes[i+1] <== poseidons[i].out;
    }


    // Na kraju, root je poslednji cvor do kog smo se popeli:
    root <== hashes[nLevels];
}