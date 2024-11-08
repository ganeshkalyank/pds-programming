#include <stdio.h>
#include <mpi/mpi.h>

int main(int argc, char **argv)
{
    int size, rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int leader = -1;

    if (rank == 0)
    {
        printf("Process %d initiating leader election\n", rank);
        MPI_Send(&leader, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
    }

    if (rank != 0)
    {
        MPI_Recv(&leader, 1, MPI_INT, (rank - 1) % size, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if (leader < rank)
            leader = rank;
    }

    if (rank != size - 1)
    {
        MPI_Send(&leader, 1, MPI_INT, (rank + 1) % size, 0, MPI_COMM_WORLD);
    }

    MPI_Bcast(&leader, 1, MPI_INT, size - 1, MPI_COMM_WORLD);

    printf("Process %d received new leader: %d\n", rank, leader);

    MPI_Finalize();
    return 0;
}