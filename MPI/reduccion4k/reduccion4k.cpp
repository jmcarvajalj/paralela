//mpicc mpi_pi.c -o mpi_pi -lm
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>
#include <math.h>

using namespace std;
using namespace cv;

void transform4kto480(Mat image, int ID, string result_image,int numprocs);
int main(int argc, char** argv) {
int done = 0,n,miyd,numprocs ,I,rc,i;
    /*if (argc < 4) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos(Ejemplo:./reduccion1080 1080.jpg result.jpg 8)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        //return 1;
    //}    
    Mat image = imread( "4k.jpg", IMREAD_COLOR);
    if(image.empty())
    {
        std::cout << "Could not read the image: " << image << std::endl;
        return 1;
    }
    string result_image = "result.jpg";

    int THREADS = 8;
    double Inicio, Fin;
    Inicio = MPI_Wtime();
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&miyd);
    if(miyd==0) printf("\nLaunching with %i processes",numprocs);
    transform4kto480(image, THREADS, result_image,numprocs);
    Fin = MPI_Wtime();
    double resultado =  Fin-Inicio;
    printf("Tiempo de respuesta: %.5f\n",resultado);
    MPI_Finalize();

    /*FILE * pFile;
    pFile = fopen("../../resultados.txt", "a");
    fprintf(pFile, "Time elapsed transforming a 1080p image to 480p using OpenMP with %d threads: %ld.%06lds\n", THREADS, (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);    
    fclose(pFile);*/   
    return 0;
}

void transform4kto480(Mat image, int ID, string result_image ,int numprocs){
    long long ITERATIONS =1e09;
    long int start,end;
    start = (ITERATIONS/numprocs)*ID;
    end = (ITERATIONS/numprocs)+1;
    long int i = start;
    do{
        
        if(image.empty()) {
        cout << "Error: the image has been incorrectly loaded." << endl;
    }

    Mat temp(image.rows + 2, image.cols + 2, CV_8UC3, Scalar(255,255, 255));
    Mat copy( image.rows*2/9, image.cols/6, CV_8UC3, Scalar(255,255, 255));

    Vec3b cpixel;
    cpixel[0] = (uchar) 0;
    cpixel[1] = (uchar) 0;
    cpixel[2] = (uchar) 0;

    temp.at<Vec3b>(0, 0) = cpixel;
    temp.at<Vec3b>(temp.rows - 1, 0) = cpixel;
    temp.at<Vec3b>(0, temp.cols - 1) = cpixel;
    temp.at<Vec3b>(temp.rows - 1, temp.cols - 1) = cpixel;


    for(int i = 0; i < image.rows ; i++) {
        for(int j = 0; j < image.cols; j++) {
            cpixel = image.at<Vec3b>(i, j);
            temp.at<Vec3b>(i+1, j+1) = cpixel;
        }
    }

    for(int i = 0; i < image.rows; i++){
        cpixel = image.at<Vec3b>(i, 0);
        temp.at<Vec3b>(i+1, 0) = cpixel;
    }

    for(int i = 0; i < image.rows; i++){
        cpixel = image.at<Vec3b>(i, image.cols - 1);
        temp.at<Vec3b>(i+1, temp.cols - 1) = cpixel;
    }

    for(int i = 0; i < image.cols; i++){
        cpixel = image.at<Vec3b>(0, i);
        temp.at<Vec3b>(0, i + 1) = cpixel;
    }

    for(int i = 0; i < image.cols; i++){
        cpixel = image.at<Vec3b>(image.rows - 1, i);
        temp.at<Vec3b>(temp.rows - 1, i + 1) = cpixel;
    }

    for(int i = 0; i < image.rows; i++){
        for(int j = 0; j < image.cols; j++){
            Vec3b mpixel = temp.at<Vec3b>(i+1, j+1);
            Vec3b upixel = temp.at<Vec3b>(i, j+1);
            Vec3b dpixel = temp.at<Vec3b>(i+2, j+1);
            Vec3b lpixel = temp.at<Vec3b>(i+1, j);
            Vec3b rpixel = temp.at<Vec3b>(i+1, j+2);

            uchar a = (mpixel[0] + upixel[0] + dpixel[0] + lpixel[0] + rpixel[0])/5;
            uchar b = (mpixel[1] + upixel[1] + dpixel[1] + lpixel[1] + rpixel[1])/5;
            uchar c = (mpixel[2] + upixel[2] + dpixel[2] + lpixel[2] + rpixel[2])/5;

            Vec3b ppixel;
            ppixel[0] = a;
            ppixel[1] = b;
            ppixel[2] = c;

            if((i+j)%2 == 0){
                if(i%2 == 0)
                    copy.at<Vec3b>((i*2)/9,j/6) = ppixel;
                else
                    copy.at<Vec3b>(((i*2)/9)+1, j/6+1) = ppixel;
            }

        }
    }    
        
        imwrite(result_image, copy);
/*  Then we create a window to display our image
    namedWindow("My first OpenCV window");

    // Finally, we display our image and ask the program to wait for a key to be pressed
    imshow("My first OpenCV window", copy);
    waitKey(0);
*/

    }while(i<end);



    
}
