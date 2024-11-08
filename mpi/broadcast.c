#include <mpi/mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    char *buf = (char *)malloc(32 * sizeof(char));

    if (rank == 0)
    {
        sprintf(buf, "Broadcast from root: Hello all!");
    }

    MPI_Bcast(buf, 32, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank != 0)
    {
        printf("%d received broadcast from root: %s\n", rank, buf);
    }

    MPI_Finalize();
    return 0;
}
