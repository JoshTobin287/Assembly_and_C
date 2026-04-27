#include <stdio.h>
#include <assert.h>

extern long REGISTER_ADDER(long a, long b);

int main() {
    long result;

    result = REGISTER_ADDER(5, 12);
    assert(result == 17);
    printf("REGISTER_ADDER(5, 12) = %ld\n", result);

    result = REGISTER_ADDER(0, 0);
    assert(result == 0);
    printf("REGISTER_ADDER(0, 0) = %ld\n", result);

    result = REGISTER_ADDER(9999, 9999);
    assert(result == 19998);
    printf("REGISTER_ADDER(9999, 9999) = %ld\n", result);

    result = REGISTER_ADDER(100, 200);
    assert(result == 300);
    printf("REGISTER_ADDER(100, 200) = %ld\n", result);

    printf("\nTest Script complete\n");
    return 0;
}