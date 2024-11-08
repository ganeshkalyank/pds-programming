#include <cuda.h>
#include <stdio.h>

__global__ void stencil(int *in, int *out, int n, int radius)
{
    int x = blockIdx.x;
    int sum = 0;
    for (int i = -radius; i <= radius; i++)
    {
        if (x + i > 0 && x + i < n)
        {
            sum += in[x + i];
        }
    }
    out[x] = sum;
}

int main()
{
    int n, *a, *b, *dA, *dB;
    scanf("%d", &n);
    a = (int *)calloc(n, sizeof(int));
    b = (int *)calloc(n, sizeof(int));
    cudaMalloc(&dA, n * sizeof(int));
    cudaMalloc(&dB, n * sizeof(int));

    for (int i = 0; i < n; i++)
    {
        scanf("%d", &a[i]);
    }

    cudaMemcpy(dA, a, n * sizeof(int), cudaMemcpyHostToDevice);

    stencil<<<n, 1>>>(dA, dB, n, 3);

    cudaMemcpy(b, dB, n * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < n; i++)
    {
        printf("%d ", b[i]);
    }
    printf("\n");

    return 0;
}
