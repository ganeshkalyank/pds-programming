#include <stdio.h>
#include <stdlib.h>
#include <mpi/mpi.h>

#define ELEMS_PER_PROC 4

int main(int argc, char **argv)
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int *arr = (int *)malloc(size * ELEMS_PER_PROC * sizeof(int));
    int *sub_arr = (int *)malloc(ELEMS_PER_PROC * sizeof(int));

    if (rank == 0)
    {
        for (int i = 0; i < ELEMS_PER_PROC * size; i++)
        {
            arr[i] = 2 * i;
        }
    }

    MPI_Scatter(arr, ELEMS_PER_PROC, MPI_INT, sub_arr, ELEMS_PER_PROC, MPI_INT, 0, MPI_COMM_WORLD);

    float sub_avg = 0.0f;
    printf("%d: ", rank);
    for (int i = 0; i < ELEMS_PER_PROC; i++)
    {
        printf("%d ", sub_arr[i]);
        sub_avg += sub_arr[i];
    }
    sub_avg /= ELEMS_PER_PROC * 1.0f;

    printf("- %f\n", sub_avg);

    float *sub_avgs = (float *)malloc(size * sizeof(float));

    MPI_Gather(&sub_avg, 1, MPI_INT, sub_avgs, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);

    if (rank == 0)
    {
        float total_avg = 0.0f;
        for (int i = 0; i < size; i++)
        {
            total_avg += sub_avgs[i];
        }
        total_avg /= size;
        printf("Total average: %f\n", total_avg);
    }

    MPI_Finalize();
    return 0;
}
