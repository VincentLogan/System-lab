#include <stdio.h>
#include <svdpi.h>

extern "C" unsigned int mul_judge(unsigned int multiplicand,
                                  unsigned int multiplier,
                                  unsigned long long int product) {
    int right = 0;
    unsigned long long int simulate_result =
        (unsigned long long int)multiplicand * multiplier;
    if (simulate_result == product) {
        right = 1;
    }
    if (!right) {
        printf("*********error***********\n");
        printf(
            "simulation multiplicand = %08x, multiplier = %08x, product = "
            "%016llx\n",
            multiplicand, multiplier, simulate_result);
        printf(
            "hardware   multiplicand = %08x, multiplier = %08x, product = "
            "%016llx\n",
            multiplicand, multiplier, product);
    } else {
        printf(
            "simulation multiplicand = %08x, multiplier = %08x, product = "
            "%016llx\n",
            multiplicand, multiplier, simulate_result);
    }

    return right;
}
