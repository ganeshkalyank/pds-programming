#include <cuda.h>
#include <stdio.h>
#include <math.h>

__global__ void odd_even(int *a, int n, int i)
{
    int j, k;
    int x = blockIdx.x * 2;
    if (i % 2 == 0 && x < n - 1)
    {
        j = a[x];
        k = a[x + 1];
        a[x] = min(j, k);
        a[x + 1] = max(j, k);
    }
    if (i % 2 == 1 && x < n - 2)
    {
        j = a[x + 1];
        k = a[x + 2];
        a[x + 1] = min(j, k);
        a[x + 2] = max(j, k);
    }
}

int main()
{
    int n, *a, *dA;
    scanf("%d", &n);
    a = (int *)calloc(n, sizeof(int));
    cudaMalloc(&dA, n * sizeof(int));

    for (int i = 0; i < n; i++)
    {
        scanf("%d", &a[i]);
    }

    cudaMemcpy(dA, a, n * sizeof(int), cudaMemcpyHostToDevice);

    for (int i = 0; i < n; i++)
    {
        odd_even<<<n / 2, 1>>>(dA, n, i);
    }

    cudaMemcpy(a, dA, n * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
    {
        printf("%d ", a[i]);
    }
    printf("\n");

    return 0;
}
