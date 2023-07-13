pragma circom  2.0.0;

// nisam znala kako da skinem ovu biblioteku pa sam samo kopirala templejte

template matElemMul (m,n) {
    signal input a[m][n];
    signal input b[m][n];
    signal output out[m][n];
    
    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            out[i][j] <== a[i][j] * b[i][j];
        }
    }
}

template matElemSum (m,n) {
    signal input a[m][n];
    signal output out;

    signal sum[m*n];
    sum[0] <== a[0][0];
    var idx = 0;
    
    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            if (idx > 0) {
                sum[idx] <== sum[idx-1] + a[i][j];
            }
            idx++;
        }
    }

    out <== sum[m*n-1];
}

template matMul (m,n,p) {
    signal input a[m][n];
    signal input b[n][p];
    signal output out[m][p];

    component matElemMulComp[m][p];
    component matElemSumComp[m][p];
    
    for (var i=0; i < m; i++) {
        for (var j=0; j < p; j++) {
            matElemMulComp[i][j] = matElemMul(1,n);
            matElemSumComp[i][j] = matElemSum(1,n);
            for (var k=0; k < n; k++) {      
                matElemMulComp[i][j].a[0][k] <== a[i][k];
                matElemMulComp[i][j].b[0][k] <== b[k][j];
            }
            for (var k=0; k < n; k++) {
                matElemSumComp[i][j].a[0][k] <== matElemMulComp[i][j].out[0][k];
            }
            out[i][j] <== matElemSumComp[i][j].out;
        }
    }
}

template linearSystemSol(m, n)
{
    signal input A[m][n];
    signal input B[n][1];
    signal input C[m][1];

    signal output out[m][1];

    component multiply = matMul(m, n, 1);
    multiply.a <== A;
    multiply.b <== B;
    out <== multiply.out;

    for(var i = 0; i < m; i++)
        out[i][0] === C[i][0];

}

component main {public [A, C]} = linearSystemSol(3, 3);