pragma circom  2.0.0;

// Pretrazi "SC" za tacna mesta koja SC proverava 

include "./node_modules/circomlib/circuits/poseidon.circom";
include "./membershipProof.circom";

// Semaphore protokol zahteva 16 <= nLevels <= 32
template Semaphore(nLevels)
{
    // Input:
    // Koristi se za pozicioniranje u Merkle stablu
    signal input identityNullifier;
    signal input indentityTrapdoor;

    // Koristi se za generisanje Merkle membership dokaza
    signal input pathIndices[nLevels];
    signal input siblings[nLevels];

    // Koristi se za sprecavanje double signaling-a:
    // JEDINI javni parametri
    signal input signalHash;
    signal input externalNullifier;
// --------------------------------
    // Output:
    // dokaz pripadnosti MT-u
    signal output root;
    // dokaz o prvobitnosti IN-a
    signal output nullifierHash;

// -------------------------------------------
    // Identity Commitment za MembProof:
    component calculateSecret = Poseidon(2);
    calculateSecret.inputs[0] <== identityNullifier;
    calculateSecret.inputs[1] <== indentityTrapdoor;
    signal secret <== calculateSecret.out;

    // Na osnovu secret vrednosti (hash(IN, IT) == s) pravimo identity commitment
    // Identity Commitment je nasa vrednost lista u Merkle stablu SC-a
    // Zapravo je hash^2(IN, IT) moj IDCommitment u MT-u
    component calculateIdCommitment = Poseidon(1);
    calculateIdCommitment.inputs[0] <== secret;
    signal idCommitment <== calculateIdCommitment.out;


    // Membership Proof :
    // dokazuje da se moja transakcija nalaziu u Pool-u
    component membershipProof = MerkleTreeInclusionProof(nLevels);
    // !!
    membershipProof.leaf <== idCommitment;

    // Obezbedjujemo potrebne ulaze za template MTInclProof:
    for(var i = 0; i < nLevels; i++)
    {
        membershipProof.pathIndices[i] <== pathIndices[i];
        membershipProof.siblings[i] <== siblings[i];
    }
    root <== membershipProof.root;     // SC ima Merkle root pa moze ovo da proveri

// -------------------------------------------    

    // Prvoerava da li je poslati (javni) signalHash dobijen kao hes eksternog i privatnog
    // na ovaj nacin dokazujem da znam identity nullifier
    // sc dodatno treba da proveri da li je ovo prvi pt da se ovaj signalHash koristi
    component calculateNullifierHash = Poseidon(2);
    calculateNullifierHash.inputs[0] <== externalNullifier;
    calculateNullifierHash.inputs[1] <== identityNullifier;
    nullifierHash <== calculateNullifierHash.out;  // SC zna signalNullifier pa proverava da li je jednak nullifierHash-u


    // Napomena: racunanje identity nullifier-a na osnovu signalNullifier-a (odnosno nh-a) je ECDLP i nije quantum resistant
}

component main{public [externalNullifier, signalHash]}  = Semaphore(20);