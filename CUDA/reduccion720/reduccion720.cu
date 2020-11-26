//standard libraries
#include <iostream>
#include <stdio.h>
#include <sys/time.h>
//opencv libraries
#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
//CUDA libraries
#include <cuda.h>
#include <cuda_runtime.h>
#include "opencv2/core/cuda.hpp"
#include "opencv2/core/cuda_types.hpp"
#include "opencv2/core/cuda_stream_accessor.hpp"
#include <device_launch_parameters.h>


using namespace std;
using namespace cv;

__global__ void transform1080to480(Mat *image, string *result_image, int n);

int main(int argc, char** argv) {

    if (argc < 5) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos #Bloques(Ejemplo:./reduccion720 720.jpg result.jpg 256 8)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }
    
    if (atoi(argv[4]) <= 0)
    {
        printf("Por favor use un numero positivo de bloques\n");
        return 1;
    }

    if (atoi(argv[3]) <= 0)
    {
        printf("Por favor use un numero positivo de hilos\n");
        return 1;
    }

    //Size of vectors
    long n = 100000;

    // Size, in bytes, of each vector
    size_t mat_size = n*sizeof(Mat);
    size_t string_size = n*sizeof(string);

    struct timeval tval_before, tval_after, tval_result;

    gettimeofday(&tval_before, NULL);

    // Allocate memory on host
    h_image = (Mat*)malloc(mat_size);
    h_result_image = (string*)malloc(string_size);

    // Allocate memory on GPU
    cudaMalloc(&d_image, mat_size);
    cudaMalloc(&d_result_image, string_size);

    //Initialize on host
    h_image = imread(argv[1], IMREAD_COLOR);

    // Copy host to device
    cudaMemcpy( d_image, h_image, mat_size, cudaMemcpyHostToDevice);

    int THREADS, BLOCKS;

    //Host input
    Mat *h_image = imread(argv[1], IMREAD_COLOR);
    
    //Host output
    string *h_result_image = argv[2];
    
    //Device input
    Mat *d_image = imread(argv[1], IMREAD_COLOR);
    
    //Device output
    string *d_result_image = argv[2];

    // Number of threads in each thread block
    THREADS = atoi(argv[3]);
     // Number of thread blocks in grid
    BLOCKS = atoi(argv[4]);

    // Execute the kernel
    transform1080to480<<<BLOCKS, THREADS>>>(d_image, d_result_image, n);
 
    // Copy array back to host
    cudaMemcpy( h_result_image, d_result_image, string_size, cudaMemcpyDeviceToHost );

    // Release device memory
    cudaFree(d_image);
    cudaFree(d_result_image);
 
    // Release host memory
    free(h_image);
    free(h_result_image);

    gettimeofday(&tval_after, NULL);

    timersub(&tval_after,&tval_before,&tval_result);

    FILE * pFile;
    pFile = fopen("/../../resultados.txt", "a");
    fprintf(pFile, "Time elapsed transforming a 1080p image to 480p using CUDA with %d threads and %d blocks: %ld.%06lds\n", THREADS, BLOCKS, (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);    
    fclose(pFile);    
    return 0;
}


__global__ void transform1080to480(Mat *image, string *result_image, int n){

    if(image.empty()) {
        cout << "Error: the image has been incorrectly loaded." << endl;
    }

    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;

    Mat temp(image.rows + 2, image.cols + 2, CV_8UC3, Scalar(255,255, 255));

    Mat copy( (image.rows*2)/3, image.cols/2, CV_8UC3, Scalar(255,255, 255));    

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
                    copy.at<Vec3b>((i*2)/3,j/2) = ppixel;
                else
                    copy.at<Vec3b>(((i*2)/3)+1, j/2+1) = ppixel;
            }
        }
    }    
        //Write resized image
        imwrite(result_image, copy);
}