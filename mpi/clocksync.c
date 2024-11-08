#include <mpi/mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, size, i;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    double local_value = rank;
    double sum = 0.0;
    double average = 0.0;

    if (rank != 0)
    {
        MPI_Send(&local_value, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }
    else
    {
        for (i = 1; i < size; i++)
        {
            double recv_value;
            MPI_Recv(&recv_value, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            sum += recv_value;
        }
        average = sum / (size - 1);
    }

    MPI_Bcast(&average, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    if (rank != 0)
    {
        printf("Process %d time before sync: %f\n", rank, local_value);
    }

    local_value = average;

    if (rank != 0)
    {
        printf("Process %d time after sync: %f\n", rank, local_value);
    }

    MPI_Finalize();
    return 0;
}
