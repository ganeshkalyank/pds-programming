#include <stdio.h>
#include <stdlib.h>
#include <mpi/mpi.h>

int main(int argc, char **argv)
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char *buf = (char *)malloc(20 * sizeof(char));

    MPI_Status status;

    if (rank == 0)
    {
        sprintf(buf, "REQUEST");
        printf("%d: requesting CS\n", rank);
        for (int i = 1; i < size; i++)
        {
            MPI_Send(buf, 20, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
        for (int i = 1; i < size; i++)
        {
            MPI_Recv(buf, 20, MPI_CHAR, i, 0, MPI_COMM_WORLD, &status);
            printf("%d: received %s from %d\n", rank, buf, i);
        }
        printf("%d entering CS\n", rank);
        sprintf(buf, "RELEASE");
        for (int i = 1; i < size; i++)
        {
            MPI_Send(buf, 20, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
    }
    else
    {
        MPI_Recv(buf, 20, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status);
        printf("%d: received %s from %d\n", rank, buf, 0);
        sprintf(buf, "OK");
        MPI_Send(buf, 20, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
        MPI_Recv(buf, 20, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status);
        printf("%d: received %s from %d\n", rank, buf, 0);
    }

    MPI_Finalize();
    return 0;
}
