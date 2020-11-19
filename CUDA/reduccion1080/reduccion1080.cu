#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <stdio.h>
#include <sys/time.h>
#include <cuda.h>

using namespace std;
using namespace cv;


__global__ void transform4kto480(Mat *image, int *ID, string *result_image);

int main(int argc, char** argv) {

    if (argc < 5) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos #Bloques(Ejemplo:./reduccion4k 4k.jpg result.jpg 1024 16)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }

    Mat *image = imread(argv[1], IMREAD_COLOR);

    Mat *copy;

    string result_image = argv[2];

    int THREADS = atoi(argv[3]);

    int N = atoi(argv[4]); //BLOQUES

    Mat *d_image;

    Mat *d_copy;

    Mat size = N * sizeof(Mat);

    cudaMalloc((void **)&d_image, size);

    image = (Mat *)malloc(size); random_ints(image, N);
    
    copy = (Mat *)malloc(size);

    cudaMemcpy(d_image, image, size, cudaMemcpyHostToDevice);

    struct timeval tval_before, tval_after, tval_result;

    gettimeofday(&tval_before, NULL);    
    
    transform4kto480<<<N,1>>>(d_image);
    // Copy result back to host
    cudaMemcpy(copy, d_copy, size, cudaMemcpyDeviceToHost);
    // Cleanup
    free(image); 
    free(copy);
    cudaFree(d_image); 
    cudaFree(d_copy);
    
    gettimeofday(&tval_after, NULL);

    timersub(&tval_after,&tval_before,&tval_result);

    FILE * pFile;
    pFile = fopen("resultados.txt", "a");
    fprintf(pFile, "Time elapsed transforming a 4k image to 480p using CUDA with %d threads and %d blocks: %ld.%06lds\n", THREADS, BLOCKS, (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);    
    fclose(pFile);    
    return 0;
}

__global__ void transform4kto480(Mat *image, int *ID, string *result_image){

    int index = threadIdx.x + blockIdx.x * blockDim.x;

    image[index]

    if(image[blockIdx.x].empty()) {
        cout << "Error: the image has been incorrectly loaded." << endl;
    }

    Mat temp[blockIdx.x](image[blockIdx.x].rows + 2, image[blockIdx.x].cols + 2, CV_8UC3, Scalar(255,255, 255));

    Mat copy[blockIdx.x]( (image[blockIdx.x].rows*4)/9, image[blockIdx.x].cols/3, CV_8UC3, Scalar(255,255, 255));
    

    Vec3b cpixel;
    cpixel[0] = (uchar) 0;
    cpixel[1] = (uchar) 0;
    cpixel[2] = (uchar) 0;

    temp[blockIdx.x].at<Vec3b>(0, 0) = cpixel;
    temp[blockIdx.x].at<Vec3b>(temp[blockIdx.x].rows - 1, 0) = cpixel;
    temp[blockIdx.x].at<Vec3b>(0, temp[blockIdx.x].cols - 1) = cpixel;
    temp[blockIdx.x].at<Vec3b>(temp[blockIdx.x].rows - 1, temp[blockIdx.x].cols - 1) = cpixel;


    for(int i = 0; i < image[blockIdx.x].rows ; i++) {
        for(int j = 0; j < image[blockIdx.x].cols; j++) {
            cpixel = image[blockIdx.x].at<Vec3b>(i, j);
            temp[blockIdx.x].at<Vec3b>(i+1, j+1) = cpixel;
        }
    }

    for(int i = 0; i < image[blockIdx.x].rows; i++){
        cpixel = image[blockIdx.x].at<Vec3b>(i, 0);
        temp[blockIdx.x].at<Vec3b>(i+1, 0) = cpixel;
    }

    for(int i = 0; i < image[blockIdx.x].rows; i++){
        cpixel = image[blockIdx.x].at<Vec3b>(i, image[blockIdx.x].cols - 1);
        temp[blockIdx.x].at<Vec3b>(i+1, temp[blockIdx.x].cols - 1) = cpixel;
    }

    for(int i = 0; i < image[blockIdx.x].cols; i++){
        cpixel = image[blockIdx.x].at<Vec3b>(0, i);
        temp[blockIdx.x].at<Vec3b>(0, i + 1) = cpixel;
    }

    for(int i = 0; i < image[blockIdx.x].cols; i++){
        cpixel = image[blockIdx.x].at<Vec3b>(image[blockIdx.x].rows - 1, i);
        temp[blockIdx.x].at<Vec3b>(temp[blockIdx.x].rows - 1, i + 1) = cpixel;
    }

    for(int i = 0; i < image[blockIdx.x].rows; i++){
        for(int j = 0; j < image[blockIdx.x].cols; j++){
            Vec3b mpixel = temp[blockIdx.x].at<Vec3b>(i+1, j+1);
            Vec3b upixel = temp[blockIdx.x].at<Vec3b>(i, j+1);
            Vec3b dpixel = temp[blockIdx.x].at<Vec3b>(i+2, j+1);
            Vec3b lpixel = temp[blockIdx.x].at<Vec3b>(i+1, j);
            Vec3b rpixel = temp[blockIdx.x].at<Vec3b>(i+1, j+2);

            uchar a = (mpixel[0] + upixel[0] + dpixel[0] + lpixel[0] + rpixel[0])/5;
            uchar b = (mpixel[1] + upixel[1] + dpixel[1] + lpixel[1] + rpixel[1])/5;
            uchar c = (mpixel[2] + upixel[2] + dpixel[2] + lpixel[2] + rpixel[2])/5;

            Vec3b ppixel;
            ppixel[0] = a;
            ppixel[1] = b;
            ppixel[2] = c;

            if((i+j)%2 == 0){
                if(i%2 == 0)
                    copy[blockIdx.x].at<Vec3b>((i*4)/9,j/3) = ppixel;
                else
                    copy[blockIdx.x].at<Vec3b>(((i*4)/9)+1, j/3+1) = ppixel;
            }
        }
    }    
        
        imwrite(*result_image, copy[blockIdx.x]);
/*  Then we create a window to display our image
    namedWindow("My first OpenCV window");

    // Finally, we display our image and ask the program to wait for a key to be pressed
    imshow("My first OpenCV window", *copy);
    waitKey(0);
*/
}