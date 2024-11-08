#include <stdio.h>
#include <stdlib.h>
#include <mpi/mpi.h>

int main(int argc, char **argv)
{
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    char *buf = (char *)malloc(20 * sizeof(char));

    MPI_Status status;

    if (rank == 0)
    {
        sprintf(buf, "Hi from root");
        for (int i = 1; i < size; i++)
        {
            MPI_Send(buf, 20, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
        printf("Message sent to all processes.\n");
        for (int i = 1; i < size; i++)
        {
            MPI_Recv(buf, 20, MPI_CHAR, i, 0, MPI_COMM_WORLD, &status);
            printf("Root received from process %d: %s\n", i, buf);
        }
    }
    else
    {
        MPI_Recv(buf, 20, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status);
        printf("%d received from root: %s\n", rank, buf);
        sprintf(buf, "ACK from %d", rank);
        MPI_Send(buf, 20, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}
