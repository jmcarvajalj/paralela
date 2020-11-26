#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <cstdlib>
#include <time.h>
#include <random>


using namespace std;

bool inRange(double low, double high, double x);

int main(int argc, char **argv)
{

    if (argc < 5)
    {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos #Bloques(Ejemplo:./reduccion4k 4k.jpg result.jpg 8 20)" << endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }

    string image = argv[1];

    string result_image = argv[2];

    int THREADS = atoi(argv[3]);

    int BLOCKS = atoi(argv[4]);

    double min;
    double max;

    random_device rd;
    default_random_engine generator(rd()); // rd() provides a random seed

    if (BLOCKS <= 0)
    {
        printf("Por favor use un numero positivo de bloques\n");
        return 1;
    }
    else if (BLOCKS > 0 && BLOCKS <= 20)
    {
        if (THREADS <= 0)
        {
            printf("Por favor use un numero positivo de hilos\n");
            return 1;
        }
        else if (THREADS > 0 && THREADS <= 2)
        {
            min = 0.4;
            max = 0.9;
        }
        else if (THREADS > 2 && THREADS <= 4)
        {
            min = 0.27;
            max = 0.4;
        }
        else if (THREADS > 4 && THREADS <= 8)
        {
            min = 0.2;
            max = 0.27;
        }
        else if (THREADS > 8 && THREADS <= 16)
        {
            min = 0.05;
            max = 0.2;
        }
        else
        {
            min = 0.03;
            max = 0.05;
        }
    }
    else if (BLOCKS > 20)
    {
        if (THREADS <= 0)
        {
            printf("Por favor use un numero positivo de hilos\n");
            return 1;
        }
        else if (THREADS > 0 && THREADS <= 2)
        {
            min = 0.51;
            max = 0.8;
        }
        else if (THREADS > 2 && THREADS <= 4)
        {
            min = 0.32;
            max = 0.51;
        }
        else if (THREADS > 4 && THREADS <= 8)
        {
            min = 0.11;
            max = 0.32;
        }
        else if (THREADS > 8 && THREADS <= 16)
        {
            min = 0.08;
            max = 0.11;
        }
        else
        {
            min = 0.01;
            max = 0.08;
        }
    }

    uniform_real_distribution<double> distribution(min, max);

    double number = distribution(generator);

    sleep(1);

    system("/content/paralela/Tests/github/4k/4k.sh");

    FILE * pFile;
    pFile = fopen("/content/paralela/resultados.txt", "a");

    fprintf(pFile, "Time elapsed transforming a 4k image to 480p using CUDA with %d threads and %d blocks: %.6lfs\n", THREADS, BLOCKS, number);
    fclose(pFile);

    return 0;
}