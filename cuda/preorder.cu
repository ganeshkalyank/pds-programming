#include <stdio.h>
#include <cuda.h>
__device__ int temp[9][9];
__global__ void traverse(int *parent, int *child, int *sibling, int *edge0, int *edge1, int *succ0, int *succ1, int *position, int *preorder)
{
    int i = threadIdx.x;
    if (parent[edge0[i]] == edge1[i])
    {                                // upward edge
        if (sibling[edge0[i]] != -1) // sibling exists
        {
            succ0[i] = edge1[i];
            succ1[i] = sibling[edge0[i]];
        }
        else if (parent[edge1[i]] != -1) // parent exists
        {
            succ0[i] = edge1[i];
            succ1[i] = parent[edge1[i]];
        }
        else // when no parent and no sibling -> root
        {
            succ0[i] = edge0[i];
            succ1[i] = edge1[i];
            preorder[edge1[i]] = 1; // position for root in preorder
        }
    }
    else // downward edge
    {
        if (child[edge1[i]] != -1) // child exists
        {
            succ0[i] = edge1[i];
            succ1[i] = child[edge1[i]];
        }
        else // No child
        {
            succ0[i] = edge1[i];
            succ1[i] = edge0[i];
        }
    }
    __syncthreads();

    // asign positions for each node
    if (parent[edge0[i]] == edge1[i]) // upward edge
    {
        position[i] = 0;
    }
    else // downward edge
    {
        position[i] = 1;
    }
    __syncthreads();

    int x;
    // list ranking algorithm
    for (int k = 0; k < 4; k++)
    {
        x = temp[succ0[i]][succ1[i]];
        position[i] = position[i] + position[x];
        succ0[i] = succ0[x];
        succ1[i] = succ1[x];
        __syncthreads();
    }

    // preorder position
    if (edge0[i] == parent[edge1[i]])
    {
        preorder[edge1[i]] = 9 + 1 - position[i];
    }
}

// initializing temp
__global__ void initialize(int *edge0, int *edge1)
{
    for (int i = 0; i < 16; i++)
    {
        temp[edge0[i]][edge1[i]] = i;
    }
}

int main()
{
    // input the binary tree
    char vertices[9] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'};
    int parent[9] = {-1, 0, 0, 1, 1, 2, 3, 3, 4};
    // add only first child
    int child[9] = {1, 3, 5, 6, 8, -1, -1, -1, -1};
    // add only right sibling
    int sibling[9] = {-1, 2, -1, 4, -1, -1, 7, -1, -1};
    // add downward edge
    int edge0[16] = {0, 1, 1, 3, 3, 6, 3, 7, 1, 4, 0, 2, 4, 8, 2, 5};
    // add upward edge
    int edge1[16] = {1, 0, 3, 1, 6, 3, 7, 3, 4, 1, 2, 0, 8, 4, 5, 2};
    int preorder[9];

    // device variables
    int *dparent, *dchild, *dsibling, *dedge0, *dedge1, *dsucc0, *dsucc1, *dposition, *dpreorder;

    // cuda event for time calculation
    cudaEvent_t stop, start;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // memory allocation for device variables
    cudaMalloc((void **)&dparent, 9 * sizeof(int));
    cudaMalloc((void **)&dchild, 9 * sizeof(int));
    cudaMalloc((void **)&dsibling, 9 * sizeof(int));
    cudaMalloc((void **)&dedge0, 16 * sizeof(int));
    cudaMalloc((void **)&dedge1, 16 * sizeof(int));
    cudaMalloc((void **)&dsucc0, 16 * sizeof(int));
    cudaMalloc((void **)&dsucc1, 16 * sizeof(int));
    cudaMalloc((void **)&dposition, 16 * sizeof(int));
    cudaMalloc((void **)&dpreorder, 9 * sizeof(int));

    // copy the tree input to device memory
    cudaMemcpy(dparent, &parent, 9 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dchild, &child, 9 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dsibling, &sibling, 9 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dedge0, &edge0, 16 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dedge1, &edge1, 16 * sizeof(int), cudaMemcpyHostToDevice);

    // record the start time
    cudaEventRecord(start, 0);

    // kernel call
    initialize<<<1, 1>>>(dedge0, dedge1);
    traverse<<<1, 16>>>(dparent, dchild, dsibling, dedge0, dedge1, dsucc0, dsucc1, dposition, dpreorder);

    // record the end time
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    // copy the results from device memory to host memory
    cudaMemcpy(&preorder, dpreorder, 9 * sizeof(int), cudaMemcpyDeviceToHost);

    // print the results
    printf("Preorder Traversal numbering to the vertices: \n");
    for (int i = 0; i < 9; i++)
    {
        printf("%c -> %d\n", vertices[i], preorder[i]);
    }

    // calculate and print the elapsed time
    float time;
    cudaEventElapsedTime(&time, start, stop);
    printf("\nTime %f ms \n", time);

    // deallocate the memory space
    cudaFree(dparent);
    cudaFree(dchild);
    cudaFree(dsibling);
    cudaFree(dedge0);
    cudaFree(dedge1);
    cudaFree(dsucc0);
    cudaFree(dsucc1);
    cudaFree(dposition);
    cudaFree(dpreorder);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    return 0;
}