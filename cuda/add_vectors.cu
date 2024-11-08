#include <stdio.h>
#include <cuda.h>

#define GRID_SIZE 2
#define BLOCK_SIZE 2

__global__ void addvs(int *a, int *b, int *c)
{
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < GRID_SIZE * BLOCK_SIZE)
        c[idx] = a[idx] + b[idx];
}

int main()
{
    int *a, *b, *c, *d_a, *d_b, *d_c;
    int size = GRID_SIZE * BLOCK_SIZE * sizeof(int);

    a = (int *)malloc(size);
    b = (int *)malloc(size);
    c = (int *)malloc(size);

    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c, size);

    for (int i = 0; i < GRID_SIZE * BLOCK_SIZE; i++)
    {
        a[i] = 2 * i;
        b[i] = 3 * i;
    }

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    addvs<<<GRID_SIZE, BLOCK_SIZE>>>(d_a, d_b, d_c);

    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < GRID_SIZE * BLOCK_SIZE; i++)
        printf("%d ", c[i]);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(a);
    free(b);
    free(c);
}
