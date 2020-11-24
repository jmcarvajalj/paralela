//standard libraries
#include <iostream>
#include <stdio.h>
#include <sys/time.h>
#include <math.h>
#include <cstdio>
#include <cmath>
#include <string>
#include <ctime>
#include <stdlib.h>
#include <unistd.h>
#include <fstream>
//opencv libraries
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
//CUDA libraries
#include <cuda.h>
#include <cuda_runtime.h>
#include "opencv2/gpu/gpu.hpp"
//#include "opencv2/gpu.hpp"
#include <device_launch_parameters.h>

using namespace std;
using namespace cv;

__global__ void transform1080to480(Mat *image, string *result_image, int n);

int main(int argc, char** argv) {

    if (argc < 5) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos #Bloques(Ejemplo:./reduccion1080 1080.jpg result.jpg 256 8)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }
    
    //Size of vectors
    long n = 100000000;

    //Host input
    //Mat *h_image = imread(argv[1], IMREAD_COLOR);
    Mat *h_image;
    //Host output
    //string *h_result_image = argv[2];
    string *h_result_image;
    //Device input
    //Mat *d_image = imread(argv[1], IMREAD_COLOR);
    Mat *d_image;
    //Device output
    //string *d_result_image = argv[2];
    string *d_result_image

    // Size, in bytes, of each vector
    size_t bytes = n*sizeof(Mat);

    struct timeval tval_before, tval_after, tval_result;

    gettimeofday(&tval_before, NULL);

    // Allocate memory on host
    h_image = (Mat*)malloc(bytes);
    h_result_image = (Mat*)malloc(bytes);

    // Allocate memory on GPU
    cudaMalloc(&d_image, bytes);
    cudaMalloc(&d_result_image, bytes);

    //Initialize on host
    Mat h_image = imread(argv[1], IMREAD_COLOR);

    // Copy host to device
    cudaMemcpy( d_image, h_image, bytes, cudaMemcpyHostToDevice);

    int THREADS, BLOCKS;

    // Number of threads in each thread block
    int THREADS = atoi(argv[3]);
     // Number of thread blocks in grid
    int BLOCKS = atoi(argv[4]);

    // Execute the kernel
    transform1080to480<<<gridSize, blockSize>>>(d_image, d_result_image, n);
 
    // Copy array back to host
    cudaMemcpy( h_result_image, d_result_image, bytes, cudaMemcpyDeviceToHost );

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

    Mat copy( (image.rows*4)/9, image.cols/3, CV_8UC3, Scalar(255,255, 255));

    if (id < n){    

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
                    copy.at<Vec3b>((i*4)/9,j/3) = ppixel;
                else
                    copy.at<Vec3b>(((i*4)/9)+1, j/3+1) = ppixel;
            }
        }
    }    
        
        imwrite(result_image, copy);
/*  Then we create a window to display our image
    namedWindow("My first OpenCV window");

    // Finally, we display our image and ask the program to wait for a key to be pressed
    imshow("My first OpenCV window", copy);
    waitKey(0);
*/}
}