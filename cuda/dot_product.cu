#include <stdio.h>
#include <cuda.h>

#define GRID_SIZE 4
#define BLOCK_SIZE 4

__global__ void product(int *a, int *b, int *c)
{
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < GRID_SIZE * BLOCK_SIZE)
        c[idx] = a[idx] * b[idx];
}

__global__ void sum(int *c, int *partial_sums)
{
    extern __shared__ int sdata[];
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int tid = threadIdx.x;
    if (idx < GRID_SIZE * BLOCK_SIZE)
        sdata[tid] = c[idx];
    else
        sdata[tid] = 0;

    __syncthreads();

    for (int i = blockDim.x / 2; i > 0; i >>= 1)
    {
        if (tid < i)
            sdata[tid] += sdata[tid + i];
        __syncthreads();
    }

    if (tid == 0)
        partial_sums[blockIdx.x] = sdata[0];
}

int main()
{
    int *a, *b, *d_a, *d_b, *d_c, *partial_sums, *d_partial_sums;
    int size = GRID_SIZE * BLOCK_SIZE * sizeof(int);

    a = (int *)malloc(size);
    b = (int *)malloc(size);
    partial_sums = (int *)malloc(GRID_SIZE * sizeof(int));

    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c, size);
    cudaMalloc(&d_partial_sums, GRID_SIZE * sizeof(int));

    for (int i = 0; i < GRID_SIZE * BLOCK_SIZE; i++)
    {
        a[i] = 2 * i;
        b[i] = 3 * i;
    }

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    product<<<GRID_SIZE, BLOCK_SIZE>>>(d_a, d_b, d_c);
    sum<<<GRID_SIZE, BLOCK_SIZE>>>(d_c, d_partial_sums);

    cudaMemcpy(partial_sums, d_partial_sums, GRID_SIZE * sizeof(int), cudaMemcpyDeviceToHost);

    int ans = 0;
    for (int i = 0; i < BLOCK_SIZE; i++)
        ans += partial_sums[i];

    cudaEventRecord(stop);

    cudaEventSynchronize(stop);

    printf("Dot product: %d\n", ans);

    float elapsedTime = 0.0f;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("Elapsed Time: %f ms\n", elapsedTime);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(a);
    free(b);
}
