#include<iostream>
#include<conio.h>
#include<cuda.h>
#include<ctime>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>
#include<device_functions.h>
#include<iomanip>

__global__ void convolutionKernel(float* inputImage, float* filter, float* outputImage, int* filterSize, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol);
__global__ void convertToGrayKernel(float* inputImage, float* outputImage, int outputWidth, int outputHeight);
__global__ void thresholdKernel(float* inputImage, float* outputImage, int thresh, int outputWidth, int outputHeight);
__global__ void prewittAddKernel(float* inputImage1, float* inputImage2, float* outputImage, int inputRow, int inputCol);
__global__ void absoluteValueKernel(float* inputImage, float* outputImage, int inputRow, int inputCol);
__global__ void addArrayKernel(float* inputImage, float* sum, int outputHeight, int outputWidth);
__global__ void resizeGrayImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth);
__global__ void resizeRGBImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth);
__global__ void splitRGBChannelsKernel(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth);
__global__ void addRGBChannelsKernel(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth);
__global__ void cutGrayImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX);
__global__ void cutRGBImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX);
__global__ void medianFilterMapKernel(float* inputImage, float* outputImage, int fH, int fW, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol);
__global__ void medianFilterSortKernel(float* inputImage, float* outputImage, float* map, int fH, int fW, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol);
__global__ void dilateKernel(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage);
__global__ void erodeKernel(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage);
__global__ void makeNumberGrayKernel(float* inputImage, int inputRow, int inputCol, float number);
__global__ void makeNumberRGBKernel(float* inputImage, int inputRow, int inputCol, float number1, float number2, float number3);
__global__ void histogramGrayKernel(float* inputImage, int inputRow, int inputCol, float* histogram);
__global__ void histogramRGBKernel(float* inputImage, int inputRow, int inputCol, float* histogram);
__global__ void kmeansGrayCalcClusterCentersKernel(float* histogram, float* clusters, float* clusterCenters, float* clusterMeans, float* clusterElementCount, int k);
__global__ void kmeansGrayClusterChoiceKernel(float* histogram, float* clusters, float* clusterCenters, float* errors, int k);
__global__ void kmeansGrayOutputKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* clusters, float* clusterCenters, int k);
__global__ void resetCECKernel(float* addr, int k);
__global__ void numberOfColorsKernel(bool* exist, int* number);
__global__ void compareRGBColorsKernel(float* inputImage, int inputRow, int inputCol, int externalId, bool* exist);
__global__ void refreshVariables(float* clusterCenters, float* clusterMeans, float* clusterElementCount);
__global__ void kmeansRGBCalcClusterCentersKernel(float* histogram, float* clusters, float* clusterCenters, float* clusterMeans, float* clusterElementCount, int k);
__global__ void kmeansRGBClusterChoiceKernel(float* histogram, float* clusters, float* clusterCenters, float* errors, int k);
__global__ void kmeansRGBOutputKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* clusters, float* clusterCenters, int k, float* colors, int colorHeight);
__global__ void addImagesGrayKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta);
__global__ void addImagesRGBKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta);
__global__ void subtractImagesGrayKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol);
__global__ void subtractImagesRGBKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol);
__global__ void clipGrayImagesKernel(float* inputImage, float* outputImage, int inputRow, int inputCol, int low, int high);
__global__ void clipRGBImagesKernel(float* inputImage, float* outputImage, int inputRow, int inputCol, int low, int high);
__global__ void otsuKernel(float* histogram, int inputRow, int inputCol, float* weightXVariance);
__global__ void histEqualKernel(float* histogram, int inputRow, int inputCol, float* newColors);
__global__ void histEqualPaintKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* newColors);
__global__ void reverseImageKernel(float* inputImage, float* outputImage, int inputRow, int inputCol);

void convolutionCuda(float* inputImage, float* filter, int inputRow, int inputCol, int filterRow, int filterCol, int strideRow, int strideCol, float* outputImage, int outputRow, int outputCol);
void convertToGrayCuda(float* inputImage, int inputRow, int inputCol, float* outputImage);
void thresholdCuda(float* inputImage, float* outputImage, int thresh, int inputRow, int inputCol);
void prewittAddCuda(float* inputImage1, float* inputImage2, float* outputImage, int inputRow, int inputCol);
void absoluteValueCuda(float* inputImage, float* outputImage, int inputRow, int inputCol);
int addArrayCuda(float* inputImage, int outputHeight, int outputWidth);
void scalePixelsCuda(float* inputImage, float* outputImage, int outputHeight, int outputWidth, float diff, float min, float newHigh, float newLow);
void resizeImageCuda(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth, int channel);
void splitRGBChannelsCuda(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth);
void addRGBChannelsCuda(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth);
void cutImageCuda(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX, int channel);
void medianFilterCuda(float* inputImage, int inputRow, int inputCol, int filterRow, int filterCol, int strideRow, int strideCol, float* outputImage, int outputRow, int outputCol);
void dilateCuda(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage);
void erodeCuda(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage);
void makeNumberCuda(float* inputImage, int inputRow, int inputCol, int channel, float number1, float number2, float number3);
void histogramCuda(float* inputImage, int inputRow, int inputCol, int channel, float* histogram);
void kmeansGrayCuda(float* inputImage, int inputRow, int inputCol, float* outputImage, int k);
bool* compareRGBColorsCuda(float* inputImage, int inputRow, int inputCol, int* outputHeight);
bool clusterCentersIsSame(float* newC, float* oldC, int colorsHeight);
void copyClusterCenters(float* newC, float* oldC, int colorsHeight);
void kmeansRGBCuda(float* inputImage, int inputRow, int inputCol, float* outputImage, int k, float* colors, int colorsHeight);
void addImagesCuda(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta, int channel);
void subtractImagesCuda(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, int channel);
void clipImagesCuda(float* inputImage, float* outputImage, int inputRow, int inputCol, int channel, int low, int high);
float otsuCuda(float* inputImage, int inputRow, int inputCol);
void histEqualCuda(float* inputImage, int inputRow, int inputCol, float* outputImage);
void histEqualCuda(float* inputImage, int inputRow, int inputCol, float* outputImage);
void reverseImageCuda(float* inputImage, float* outputImage, int inputRow, int inputCol);