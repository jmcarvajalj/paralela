#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <pthread.h>
#include <iostream>
#include <sys/time.h>
#include <stdio.h>

using namespace std;
using namespace cv;

//Mat image;
int num_threads;

void* transform720to480(void* arg);

struct transform720to480_struct{
    Mat image;
    Mat result;
};


int main(int argc, char** argv) {
    // We'll start by loading an image from the drive
    // Check the number of parameters
    if (argc < 4) {
        // Tell the user how to run the program
        cerr << "Uso:" << argv[0] << " Imagen-Entrada Imagen-Salida #Hilos (Ejemplo:./reduccion 720.jpg result.jpg 8)"<< endl;
        /* "Usage messages" are a conventional way of telling the user
         * how to run a program if they enter the command incorrectly.
         */
        return 1;
    }

    struct timeval tval_before, tval_after, tval_result;

    gettimeofday(&tval_before, NULL);
    //Mat image = imread(argv[1], IMREAD_COLOR);
    num_threads = atoi(argv[3]);
    //Trhead ID
    pthread_t tids[num_threads];
    //Create Attributes
    struct transform720to480_struct args[num_threads];

    for(int i=0; i<num_threads;i++){    
    args[i].image = imread(argv[1], IMREAD_COLOR);    
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_create(&tids[i],&attr, transform720to480, &args[i]);
    }
    //Wait until thread has done its work
    for(int i=0; i<num_threads;i++){
    pthread_join(tids[i], NULL);
    imwrite(argv[2], args[i].result);
    } 
    
    gettimeofday(&tval_after, NULL);

    timersub(&tval_after,&tval_before,&tval_result);

    FILE * pFile;
    pFile = fopen("resultados.txt", "a");
    fprintf(pFile, "Time elapsed with %d threads: %ld.%06lds\n", num_threads, (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);
    fclose(pFile);    
    return 0;
}

void* transform720to480(void* arg){

    struct transform720to480_struct *arg_struct = (struct transform720to480_struct*) arg;
    
    if(arg_struct->image.empty()) {
        cout << "Error: the arg_struct->image has been incorrectly loaded." << endl;
    }

    Mat temp(arg_struct->image.rows + 2, arg_struct->image.cols + 2, CV_8UC3, Scalar(255,255, 255)); 

    Mat copy( (arg_struct->image.rows*2)/3, arg_struct->image.cols/2, CV_8UC3, Scalar(255,255, 255));

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
                    copy.at<Vec3b>((i*2)/3,j/2) = ppixel;    
                    //aqui se anexa el cambio y asignacion de pixeles ala nueva imagen
                else
                    copy.at<Vec3b>(((i*2)/3)+1, j/2+1) = ppixel;
            }
        }
    }

    arg_struct->result = copy;
    pthread_exit(0);
}