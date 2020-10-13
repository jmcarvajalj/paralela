#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>

#include <iostream>

using namespace cv;

int transform4kto480(Mat image);

int main(int argc, char** argv) {
    // We'll start by loading an image from the drive
    Mat image = imread("4k.jpg", IMREAD_COLOR);
    transform4kto480(image);
    return 0;
}

int transform4kto480(Mat image){

if(image.empty()) {
        std::cout << "Error: the image has been incorrectly loaded." << std::endl;
        return 0;
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

    imwrite("4kto480.jpg", copy);
/*
    // Then we create a window to display our image
    namedWindow("My first OpenCV window");

    // Finally, we display our image and ask the program to wait for a key to be pressed
    imshow("My first OpenCV window", copy);
    waitKey(0);
*/
    return 0;

}