#include <cstdio>
#include <ctime>

using namespace std;

const int MAX_COEFF = 103;

void random_polynomial(int* p,  int n)
{
    for (int i=0; i<n; i++) {
        p[i] = rand() % MAX_COEFF;
    }
}

__global__ void calculate_products(int *prods, int *x, int *y, size_t n) 
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    prods[index] = (x[blockIdx.x] * y[threadIdx.x]) % MAX_COEFF;
}


__global__ void reduce_polynomial(int *prods, int *ans, size_t n)
{
    // combine like terms
    int i, j;
    if (blockIdx.x <= (2*n-2)/2)
    {
        i = blockIdx.x, j = 0;
    }
    else
    {
        i = n-1, j = (blockIdx.x % n) + 1;
    }
    while (i >= 0 && j < n)
    {
        ans[blockIdx.x] = (ans[blockIdx.x] + prods[i*n + j]) % MAX_COEFF;
        i--;
        j++;
    }
}

int main() {
    srand(time(NULL));
    const int n = 1024; // 2^10
    int *X = NULL;
    int *Y = NULL;
    int *P = NULL; // products
    int *Poly = NULL;
    X = new int[n];
    Y = new int[n];
    P = new int[n*n];
    Poly = new int[2*n-1];

    // Initialize values
    random_polynomial(X, n);
    random_polynomial(Y, n);

    for (int i = 0; i < n*n; i++)
    {
        P[i] = 0;
    }

    for (int i = 0; i < 2*n-1; i++)
    {
        Poly[i] = 0;
    }

    // Products
	int *Xd, *Yd, *Pd;
    cudaMalloc((void **)&Xd, sizeof(int)*n);
    cudaMalloc((void **)&Yd, sizeof(int)*n);
    cudaMalloc((void **)&Pd, sizeof(int)*n*n);

	cudaMemcpy(Xd, X, sizeof(int)*n, cudaMemcpyHostToDevice);
    cudaMemcpy(Yd, Y, sizeof(int)*n, cudaMemcpyHostToDevice);
    cudaMemcpy(Pd, P, sizeof(int)*n*n, cudaMemcpyHostToDevice);

    calculate_products<<<n, n>>>(Pd, Xd, Yd, n);

    int *Polyd;
    cudaMalloc((void **)&Polyd, sizeof(int)*2*n-1);

    cudaMemcpy(Polyd, Poly, sizeof(int)*2*n-1, cudaMemcpyHostToDevice);

    // Reduction kernel
    reduce_polynomial<<<2*n-1, 1>>>(Pd, Polyd, n);
    cudaMemcpy(Poly, Polyd, sizeof(int)*2*n-1, cudaMemcpyDeviceToHost);

    // Print input, output
    for (int i = 0; i < n; ++i) printf("%2d ", X[i]);
    printf("\n\n");
    for (int i = 0; i < n; ++i) printf("%2d ", Y[i]);
    printf("\n\n");
    for (int i = 0; i < 2*n-1; ++i) printf("%2d ", Poly[i]);
    printf("\n\n");
    
    delete [] X;
    delete [] Y;
    delete [] P;
    delete [] Poly;

	
	cudaFree(Xd);
    cudaFree(Yd);
    cudaFree(Pd);
    cudaFree(Polyd);
	
	return 0;
}