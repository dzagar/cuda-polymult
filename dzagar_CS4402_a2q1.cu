// CS 4402 - Dana Zagar - 250790176
#include <cstdio>
#include <ctime>

using namespace std;

// A small prime number to prevent overflow and make verification feasible.
const int MAX_COEFF = 103;

// Print polynomial output.
void print_polynomial(int* poly, int range)
{
    for (int i = 0; i < range; i++) 
    {
        printf("%2d ", poly[i]);
    }
    printf("\n\n");
}

// Generates a random polynomial of size n.
void random_polynomial(int* p,  int n)
{
    for (int i=0; i<n; i++) {
        p[i] = rand() % MAX_COEFF;
    }
}

// Serial C function to find reduced polynomial product.
// For verification purposes.
void multiply_polynomials_serial(int *x, int *y, int size, int *ans)
{
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            ans[i+j] = (ans[i+j] + x[i] * y[j]) % MAX_COEFF;
        }
    }
}

// First CUDA kernel to calculate the product terms over two given polynomials
// of size n, given n thread-blocks and n threads per.
__global__ void calculate_products(int *prods, int *x, int *y, size_t n) 
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    prods[index] = (x[blockIdx.x] * y[threadIdx.x]) % MAX_COEFF;
}

// Second CUDA kernel to reduce the products by combining like terms on each
// diagonal of the "2d" product matrix.
__global__ void reduce_polynomial(int *prods, int *ans, size_t n)
{
    int i, j;
    
    // Envision the product array as a 2d matrix tilted like a diamond.
    // Each block represents a row of the diamond, i.e. a diagonal.
    // If the block index is within the first half of the diamond, the
    // block index dictates the row index.
    if (blockIdx.x <= (2*n-2)/2)
    {
        i = blockIdx.x, j = 0;
    }
    // Otherwise, the block index dictates the column index.
    else
    {
        i = n-1, j = (blockIdx.x % n) + 1;
    }

    // Sum over the diagonal given by the block index.
    while (i >= 0 && j < n)
    {
        ans[blockIdx.x] = (ans[blockIdx.x] + prods[i*n + j]) % MAX_COEFF;
        i--;
        j++;
    }
}

int main() {
    srand(time(NULL));
    int exponent;

    // Input the number of terms.
    printf("Input the desired number of terms in the polynomials. Enter an exponent on 2 [valid from 1-10] to define 2^input terms: ");
    scanf("%d", &exponent);

    if (exponent < 1 || exponent > 10)
    {
        printf("Invalid input. Program will terminate.\n\n");
        return 0;
    }

    int n = 1 << exponent; // Number of terms is 2^exponent.
    printf("%d terms; input polynomials are of degree %d.\n\n", n, n-1);

    int *X = NULL; // First polynomial of degree n-1.
    int *Y = NULL; // Second polynomial of degree n-1.
    int *P = NULL; // Interim products.
    int *Poly = NULL; // Final.
    int *PolyV = NULL; // Verification answer.
    X = new int[n];
    Y = new int[n];
    P = new int[n*n];
    Poly = new int[2*n-1];
    PolyV = new int[2*n-1];

    // Initialize values.
    random_polynomial(X, n);
    random_polynomial(Y, n);

    for (int i = 0; i < n*n; i++)
    {
        P[i] = 0;
    }

    for (int i = 0; i < 2*n-1; i++)
    {
        Poly[i] = 0;
        PolyV[i] = 0;
    }

    // Step 1: Calculating products.
	int *Xd, *Yd, *Pd;
    cudaMalloc((void **)&Xd, sizeof(int)*n);
    cudaMalloc((void **)&Yd, sizeof(int)*n);
    cudaMalloc((void **)&Pd, sizeof(int)*n*n);

	cudaMemcpy(Xd, X, sizeof(int)*n, cudaMemcpyHostToDevice);
    cudaMemcpy(Yd, Y, sizeof(int)*n, cudaMemcpyHostToDevice);
    cudaMemcpy(Pd, P, sizeof(int)*n*n, cudaMemcpyHostToDevice);

    calculate_products<<<n, n>>>(Pd, Xd, Yd, n);

    // Step 2: Reducing like terms.
    int *Polyd;
    cudaMalloc((void **)&Polyd, sizeof(int)*2*n-1);

    cudaMemcpy(Polyd, Poly, sizeof(int)*2*n-1, cudaMemcpyHostToDevice);

    reduce_polynomial<<<2*n-1, 1>>>(Pd, Polyd, n);
    cudaMemcpy(Poly, Polyd, sizeof(int)*2*n-1, cudaMemcpyDeviceToHost);

    // Print input, output.
    printf("CUDA Program Output\n\n");
    print_polynomial(X, n);
    print_polynomial(Y, n);
    print_polynomial(Poly, 2*n-1);

    // Step 3: Verify using serial C function.
    printf("Verification with Serial C Output\n\n");
    multiply_polynomials_serial(X, Y, n, PolyV);
    print_polynomial(PolyV, 2*n-1);
    
    // Free memory.
    delete [] X;
    delete [] Y;
    delete [] P;
    delete [] Poly;
    delete [] PolyV;
	
	cudaFree(Xd);
    cudaFree(Yd);
    cudaFree(Pd);
    cudaFree(Polyd);
	
	return 0;
}
