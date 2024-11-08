#include <cuda.h>
#include <stdio.h>

#define ROWS 4
#define COLS 4

__global__ void transpose(int *a, int *b)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;
    int from, to;
    if (x < ROWS && y < COLS)
    {
        from = x + y * ROWS;
        to = y + x * ROWS;
        b[to] = a[from];
    }
}

int main()
{
    int *a, *b, *dA, *dB;
    a = (int *)calloc(ROWS * COLS, sizeof(int));
    b = (int *)calloc(ROWS * COLS, sizeof(int));

    cudaMalloc(&dA, ROWS * COLS * sizeof(int));
    cudaMalloc(&dB, ROWS * COLS * sizeof(int));

    for (int i = 0; i < ROWS; i++)
    {
        for (int j = 0; j < COLS; j++)
        {
            scanf("%d", a + i * COLS + j);
        }
    }

    cudaMemcpy(dA, a, ROWS * COLS * sizeof(int), cudaMemcpyHostToDevice);

    transpose<<<dim3(2, 2), dim3(2, 2)>>>(dA, dB);

    cudaMemcpy(b, dB, ROWS * COLS * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < ROWS; i++)
    {
        for (int j = 0; j < COLS; j++)
        {
            printf("%d ", b[i * COLS + j]);
        }
        printf("\n\n");
    }

    return 0;
}
