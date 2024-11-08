#include <stdio.h>

__global__ void merge_arrays(int *arr, int n)
{
    int i = threadIdx.x;
    int low, high, index;
    if (i < n / 2)
    {
        low = n / 2;
        high = n - 1;
    }
    else
    {
        low = 0;
        high = n / 2 - 1;
    }
    int x = arr[i];
    while (low < high)
    {
        index = (low + high) / 2;
        if (x < arr[index])
        {
            high = index - 1;
        }
        else
        {
            low = index + 1;
        }
    }
    arr[high + i - n / 2 - 1] = x;
}

int main()
{
    int *arr = (int *)malloc(10 * sizeof(int));
    for (int i = 0; i < 5; i++)
    {
        arr[i] = i + 1;
        arr[i + 5] = i + 2;
    }
    for (int i = 0; i < 10; i++)
    {
        printf("%d ", arr[i]);
    }
    printf("\n");
    int *arr_d;
    cudaMalloc(&arr_d, 10 * sizeof(int));
    cudaMemcpy(arr_d, arr, 10 * sizeof(int), cudaMemcpyHostToDevice);
    merge_arrays<<<1, 10>>>(arr_d, 10);
    cudaMemcpy(arr, arr_d, 10 * sizeof(int), cudaMemcpyDeviceToHost);
    for (int i = 0; i < 10; i++)
    {
        printf("%d ", arr[i]);
    }
    printf("\n");
}
