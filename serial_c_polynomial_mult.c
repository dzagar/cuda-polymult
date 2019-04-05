#include <stdio.h>
#include <stdlib.h>

const int MAX_DEGREE = 1024;
const int MAX_COEFF = 103;

void random_polynomial(int* p,  int n)
{
    for (int i=0; i<n; i++) {
        p[i] = rand() % MAX_COEFF;
    }
}

void multiply_polynomials(int *x, int *y, int size, int *ans, int ansSize)
{
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            ans[i+j] = (ans[i+j] + x[i] * y[j]) % MAX_COEFF;
        }
    }
}

void print_polynomial(int* p, int n)
{
    for (int i=0; i<n; i++) 
    {
      printf("%d ", p[i]);
    }
    printf("\n");
}

int main(void) 
{
    int *x;
    int *y;
    int *ans;
    int size;

    srand(40);
    // Generate degree between 1 and 2^10.
    //size = rand() % MAX_DEGREE + 1;
    size = 4;
    printf("Size: %d\n",size);

    // Generate x
    x = (int *) malloc(size * sizeof(int));
    random_polynomial(x, size);
    print_polynomial(x, size);

    // Generate y
    y = (int *) malloc(size * sizeof(int));
    random_polynomial(y, size);
    print_polynomial(y, size);

    // Initialize answer
    int ansSize = 2 * size - 1;
    ans = (int *) malloc(sizeof(int) * ansSize);
    for (int i = 0; i < ansSize; i++) 
    {
        ans[i] = 0;
    }

    // Multiply polynomials into answer
    multiply_polynomials(x, y, size, ans, ansSize);
    print_polynomial(ans, ansSize);

    // Free
    free(ans);
    free(x);
    free(y);
    return 0;
}