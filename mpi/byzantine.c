#include <mpi/mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int proposal = rank;
    int decision;

    int *proposals = (int *)malloc(size * sizeof(int));
    MPI_Allgather(&proposal, 1, MPI_INT, proposals, 1, MPI_INT, MPI_COMM_WORLD);

    int *counts = (int *)calloc(size, sizeof(int));
    for (int i = 0; i < size; i++)
    {
        counts[proposals[i]]++;
    }

    int max_count = 0;
    for (int i = 0; i < size; i++)
    {
        if (counts[i] > max_count)
        {
            max_count = counts[i];
            decision = i;
        }
    }

    MPI_Bcast(&decision, 1, MPI_INT, 0, MPI_COMM_WORLD);

    printf("Process %d decided on %d\n", rank, decision);

    free(proposals);
    free(counts);

    MPI_Finalize();
    return 0;
}
