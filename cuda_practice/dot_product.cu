#include <cuda.h>
#include <stdio.h>

__global__ void dotProduct(int *a, int *b, int *c, int n, int *total_sum)
{
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < n)
    {
        c[idx] = a[idx] * b[idx];
    }
    atomicAdd(total_sum, c[idx]);
}

int main()
{
    int *a, *b, *c, *dA, *dB, *dC;
    int n;

    scanf("%d", &n);
    a = (int *)calloc(n, sizeof(int));
    b = (int *)calloc(n, sizeof(int));
    c = (int *)calloc(n, sizeof(int));
    for (int i = 0; i < n; i++)
    {
        scanf("%d", a + i);
    }
    for (int i = 0; i < n; i++)
    {
        scanf("%d", b + i);
    }

    cudaMalloc(&dA, n * sizeof(int));
    cudaMalloc(&dB, n * sizeof(int));
    cudaMalloc(&dC, n * sizeof(int));

    cudaMemcpy(dA, a, n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dB, b, n * sizeof(int), cudaMemcpyHostToDevice);

    int *total_sum, *dTotalSum;
    total_sum = (int *)calloc(1, sizeof(int));
    cudaMalloc(&dTotalSum, sizeof(int));
    cudaMemcpy(&dTotalSum, &total_sum, sizeof(int), cudaMemcpyHostToDevice);

    dotProduct<<<10, 10>>>(dA, dB, dC, n, dTotalSum);

    cudaMemcpy(c, dC, n * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(total_sum, dTotalSum, sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
    {
        printf("%d ", c[i]);
    }
    printf("\n");

    printf("%d\n", *total_sum);

    free(a);
    free(b);
    free(c);
    free(total_sum);
    cudaFree(dA);
    cudaFree(dB);
    cudaFree(dC);
    cudaFree(dTotalSum);

    return 0;
}
