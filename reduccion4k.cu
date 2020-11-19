#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <stdio.h>
#include <sys/time.h>
#include <cuda.h>

int id_hilo;

using namespace std;
using namespace cv;

__global__ void transform4kto480(Mat image, string result_image);

int main(int argc, char** argv) {

    if (argc < 5) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos #Bloques(Ejemplo:./reduccion4k 4k.jpg result.jpg 1024 16)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }

    Mat image = imread(argv[1], IMREAD_COLOR);

    string result_image = argv[2];

    int THREADS = atoi(argv[3]);

    int BLOCKS = atoi(argv[4]);

    struct timeval tval_before, tval_after, tval_result;

    gettimeofday(&tval_before, NULL);
    
    dim3 dimGrid(BLOCKS,1,1); 
	dim3 dimBlock(THREADS,1,1);
	double *sumaHost, *sumaDispositivo;
    size_t size = BLOCKS*THREADS*sizeof(double);
    
    sumaHost = (double *)malloc(size); 
	cudaMalloc((void **) &sumaDispositivo, size);
    cudaMemset(sumaDispositivo, 0, size);
    
    transform4kto480 <<<dimGrid, dimBlock>>> (sumaDispositivo, BLOCKS, THREADS);
    cudaMemcpy(sumaHost, sumaDispositivo, size, cudaMemcpyDeviceToHost);
    for(id_hilo=0; id_hilo<THREADS*BLOCKS; id_hilo++)
		pi += sumaHost[id_hilo];
	pi *= paso;
    
    gettimeofday(&tval_after, NULL);

    timersub(&tval_after,&tval_before,&tval_result);

    FILE * pFile;
    pFile = fopen("resultados.txt", "a");
    fprintf(pFile, "Time elapsed transforming a 4k image to 480p using CUDA with %d threads and %d blocks: %ld.%06lds\n", THREADS, BLOCKS, (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);    
    fclose(pFile);    
    return 0;
}


__global__ void transform4kto480(Mat image, string result_image){
    int i;
    double x;
    int index = blockIdx.x*blockDim.x+threadIdx.x;
	for (i=index; i< numero_iteraciones; i+=THREADS*BLOCKS) {
		x = (i+0.5)*paso;
		suma[index] += 4.0/(1.0+x*x);
	}

    if(image.empty()) {
        cout << "Error: the image has been incorrectly loaded." << endl;
    }

    Mat temp(image.rows + 2, image.cols + 2, CV_8UC3, Scalar(255,255, 255));
    
    //tamaño de 4k a 480
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
}