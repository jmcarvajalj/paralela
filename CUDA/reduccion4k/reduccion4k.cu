#include <stdio.h>
#include <cuda.h>
#include <sys/time.h>cc

#define ITERACIONES  2e09  
#define NUMERO_BLOQUES 40 
#define NUMERO_HILOS 1
int id_hilo;


struct transform4kto480_struct{
    Mat image;
    Mat result;
};


__global__ void* transform4kto480(void* arg,int iteraciones, int hilos, int bloques){
    int i;
	int index = blockIdx.x*blockDim.x+threadIdx.x;
	for (i=index; i< numero_iteraciones; i+=numero_hilos*numero_bloques) {

        struct transform4kto480_struct *arg_struct = (structtransform4kto480_struct*) arg;
        
        if(arg_struct->image.empty()) {
            cout << "Error: the arg_struct->image has been incorrectly loaded." << endl;
        }

        Mat temp(arg_struct->image.rows + 2, arg_struct->image.cols + 2, CV_8UC3, Scalar(255,255, 255));
        
        Mat copy( arg_struct->image.rows*2/9, arg_struct->image.cols/6, CV_8UC3, Scalar(255,255, 255));

        Vec3b cpixel;
        cpixel[0] = (uchar) 0;
        cpixel[1] = (uchar) 0;
        cpixel[2] = (uchar) 0;

        temp.at<Vec3b>(0, 0) = cpixel;
        temp.at<Vec3b>(temp.rows - 1, 0) = cpixel;
        temp.at<Vec3b>(0, temp.cols - 1) = cpixel;
        temp.at<Vec3b>(temp.rows - 1, temp.cols - 1) = cpixel;


        for(int i = 0; i < arg_struct->image.rows ; i++) {
            for(int j = 0; j < arg_struct->image.cols; j++) {
                cpixel = arg_struct->image.at<Vec3b>(i, j);
                temp.at<Vec3b>(i+1, j+1) = cpixel;
            }
        }

        for(int i = 0; i < arg_struct->image.rows; i++){
            cpixel = arg_struct->image.at<Vec3b>(i, 0);
            temp.at<Vec3b>(i+1, 0) = cpixel;
        }

        for(int i = 0; i < arg_struct->image.rows; i++){
            cpixel = arg_struct->image.at<Vec3b>(i, arg_struct->image.cols - 1);
            temp.at<Vec3b>(i+1, temp.cols - 1) = cpixel;
        }

        for(int i = 0; i < arg_struct->image.cols; i++){
            cpixel = arg_struct->image.at<Vec3b>(0, i);
            temp.at<Vec3b>(0, i + 1) = cpixel;
        }

        for(int i = 0; i < arg_struct->image.cols; i++){
            cpixel = arg_struct->image.at<Vec3b>(arg_struct->image.rows - 1, i);
            temp.at<Vec3b>(temp.rows - 1, i + 1) = cpixel;
        }

        for(int i = 0; i < arg_struct->image.rows; i++){
            for(int j = 0; j < arg_struct->image.cols; j++){
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

        arg_struct->result = copy;
    }
}



int main(void) {
    struct timeval tval_before, tval_after, tval_result;
    gettimeofday(&tval_before, NULL); 

	dim3 dimGrid(NUMERO_BLOQUES,1,1); 
	dim3 dimBlock(NUMERO_HILOS,1,1);
    struct transform4kto480_struct *arg_struct;
    struct transform4kto480_struct host = (void *)malloc(size);
	size_t size = NUMERO_BLOQUES*NUMERO_HILOS*sizeof(double);

	cudaMalloc((void **) &arg_struct, size);
	cudaMemset(arg_struct, 0, size);

    transform4kto480 <<<dimGrid, dimBlock>>> (arg_struct, ITERACIONES, NUMERO_HILOS, NUMERO_BLOQUES);
	
	cudaMemcpy(host, arg_struct, size, cudaMemcpyDeviceToHost);

    gettimeofday(&tval_after, NULL);
    timersub(&tval_after, &tval_before, &tval_result);

    printf("Tiempo transcurrido: %ld.%06ld segundos\n", (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);

    free(host);
	cudaFree(arg_struct);

	return 0;
}