#include <opencv2/opencv.hpp>
#include <opencv2/cudaimgproc.hpp>
#include <opencv2/cudawarping.hpp>
using namespace std;
using namespace cv;
using namespace cv::cuda;
static void gpuResize(Mat in, Mat &out){
    double k = in.cols/416.;
    cuda::GpuMat gpuInImage;
    cuda::GpuMat gpuOutImage;
    gpuInImage.upload(in);
    const Size2i &newSize = Size(416, in.rows / k);
    cout << "newSize " << newSize<< endl;
    cuda::resize(gpuInImage, gpuOutImage, newSize);
    gpuOutImage.download(out);
}

int main(){
    Mat im = Mat::zeros(Size(832,832),CV_8UC3);
    Mat out;
    if (getCudaEnabledDeviceCount() == 0){
        return cerr << "No GPU found or the library is compiled without CUDA support" << endl, -1;
    }
    cv::cuda::printShortCudaDeviceInfo(cv::cuda::getDevice());
    gpuResize(im,out);
    cout << "real size="<<out.size() <<endl;
}