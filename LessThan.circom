pragma circom  2.0;

include "./node_modules/circomlib/circuits/comparators.circom"

template LessThan10()
{
    signal input in;
    signal output out;

    // instanciramo teplejt LessThan iz comparators biblioteke
    // kako bismo mogli koriscenjem promenljive 'lt' da poredimo brojeve
    // velicina binarnog zapisa broja je 32b
    component lt = LessThan(32);

    // stavljamo constraint i dodeljujemo vrednost lokalnoj promenljivoj u templejtu LessThan
    // in[0] oznacava promenljivu sa leve strane operatora poredjenja
    lt.in[0] <== in;

    // zanima nas da li je 'in' manji od 10
    // dakle, sa desne strane operatora je broj 10
    lt.in[1] <== 10;

    // rezultat naseg templejta je ujedno rezultat biblioteckog poredjenja
    out <== lt.out;
}