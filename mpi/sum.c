#include <stdio.h>
#include <stdlib.h>
#include <mpi/mpi.h>

int main(int argc, char **argv)
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int total_sum;
    int local_sum = 2 * rank;

    MPI_Reduce(&local_sum, &total_sum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0)
    {
        printf("Total sum: %d\n", total_sum);
    }

    MPI_Finalize();
    return 0;
}
