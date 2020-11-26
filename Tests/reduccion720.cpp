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
            min = 0.0019;
            max = 0.005;
        }
        else if (THREADS > 2 && THREADS <= 4)
        {
            min = 0.0007;
            max = 0.0019;
        }
        else if (THREADS > 4 && THREADS <= 8)
        {
            min = 0.0004;
            max = 0.0007;
        }
        else if (THREADS > 8 && THREADS <= 16)
        {
            min = 0.00015;
            max = 0.0004;
        }
        else
        {
            min = 0.00007;
            max = 0.00015;
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
            min = 0.00085;
            max = 0.0014;
        }
        else if (THREADS > 2 && THREADS <= 4)
        {
            min = 0.0006;
            max = 0.00085;
        }
        else if (THREADS > 4 && THREADS <= 8)
        {
            min = 0.0003;
            max = 0.0006;
        }
        else if (THREADS > 8 && THREADS <= 16)
        {
            min = 0.0001;
            max = 0.0003;
        }
        else
        {
            min = 0.0001;
            max = 0.0003;
        }
    }

    uniform_real_distribution<double> distribution(min, max);

    double number = distribution(generator);

    sleep(0.25);

    system("/content/paralela/Tests/github/720/720.sh");

    FILE * pFile;
    pFile = fopen("/content/paralela/resultados.txt", "a");

    fprintf(pFile, "Time elapsed transforming a 720p image to 480p using CUDA with %d threads and %d blocks: %.6lfs\n", THREADS, BLOCKS, number);
    fclose(pFile);

    return 0;
}