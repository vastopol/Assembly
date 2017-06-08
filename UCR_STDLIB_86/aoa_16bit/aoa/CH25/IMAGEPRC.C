#include <stdio.h>
#include <stdlib.h>

typedef unsigned char   BYTE;
typedef BYTE IMAGE[251][256];

void main (void) {
    int     h, i, j, k, l, sum, iterations;
    IMAGE   *datain, *dataout;
    FILE    *f, *g;

    f = fopen ("roller1.raw", "rb");
    g = fopen ("roller2.raw", "wb");
    datain  = malloc (sizeof (IMAGE));
    dataout = malloc (sizeof (IMAGE));
    fread (datain, sizeof (IMAGE), 1, f);
    printf ("Enter number of iterations: ");
    scanf ("%d", &iterations);
    printf ("Computing result\n");

    for (i = 0; i < 251; ++i)
        for (j = 0; j < 256; ++j)
            (*dataout)[i][j] = (*datain)[i][j];

    for (h = 0; h < iterations; ++h) {
        for (i = 1; i < 250; ++i)
            for (j = 1; j < 255; ++j) {
                sum = 0;
                for (k = -1; k < 2; ++k)
                    for (l = -1; l < 2; ++l)
                        sum += (*datain)[i+k][j+l];
                (*dataout)[i][j] = (sum + (*datain)[i][j]*7 + 1) / 16;
            }
        for (i = 0; i < 251; ++i)
            for (j = 0; j < 256; ++j)
                (*datain)[i][j] = (*dataout)[i][j];
    }

    printf ("Writing results\n");
    fwrite (dataout, sizeof (IMAGE), 1, g);
    fclose (f);
    fclose (g);
}
