#pragma once
#include<iostream>
#include<conio.h>
#include<cuda.h>
#include<ctime>
#include<iomanip>
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp" 

using namespace cv;
using namespace std;

namespace imp {
    void printVec1d(float* vec, int h);
    void printVec2d(float* mat1, int h, int w);
    void printVec3d(float* mat1, int h, int w);
    void printVec(float* mat1, int h, int w, int channel);
    int* outputSizeCalc(int row, int col, int filterRow, int filterCol, int strideRow, int strideCol);

class Image {
    public:
        int height, width, channel;
        float* data = NULL;
        void printSize() {
            cout << endl << "h,w,c: " << this->height << " " << this->width << " " << this->channel << endl;
        }        
        Image() {

        }        
        Image(int h, int w, int c) {
            this->height = h;
            this->width = w;
            this->channel = c;
            this->data = (float*)malloc(sizeof(float) * h * w * c);
        }
        void makeMeanFilter(int h, int w) {
            this->height = h;
            this->width = w;
            this->channel = 1;
            if (this->data != NULL)
                delete[] this->data;
            this->data = (float*)malloc(sizeof(float) * h * w);
            float mean = 1.0 / (w * h);
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    this->data[i * w + j] = mean;
                }
            }
        }
        void makeLaplaceFilter() {
            this->height = 3;
            this->width = 3;
            this->channel = 1;
            int h = this->height, w = this->width;
            if (this->data != NULL)
                delete[] this->data;
            this->data = (float*)malloc(sizeof(float) * h * w);
            float fl[] = { 0,1,0,1,-4,1,0,1,0 };
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    this->data[i * w + j] = fl[i * w + j];
                }
            }
        }
        void makeVerticalPrewittFilter() {
            this->height = 3;
            this->width = 3;
            this->channel = 1;
            int h = this->height, w = this->width;
            if (this->data != NULL)
                delete[] this->data;
            this->data = (float*)malloc(sizeof(float) * h * w);
            float fl[] = { -1,0,1,-1,0,1,-1,0,1 };
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    this->data[i * w + j] = fl[i * w + j];
                }
            }
        }
        void makeHorizontalPrewittFilter() {
            this->height = 3;
            this->width = 3;
            this->channel = 1;
            int h = this->height, w = this->width;
            if (this->data != NULL)
                delete[] this->data;
            this->data = (float*)malloc(sizeof(float) * h * w);
            float fl[] = { -1,-1,-1,0,0,0,1,1,1 };
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    this->data[i * w + j] = fl[i * w + j];
                }
            }
        }
    };

    void printImage(Image image);

    void printHistogram(Image hist);

    Image matToImage(Mat image);

    Mat imageToMat(Image newImage);

    float* matToFloat(Mat image);

    Mat floatToMat(float* newImage, int r, int c, int ch);

    Image readImage(string path);

    Image readImage(const char path[]);

    Image readImage(string path, int h, int w);

    Image readImage(const char path[], int h, int w);

    void writeImage(Image image, string path);

    void writeImage(Image image, const char path[]);

    void showImage(Image image);

    void showImages(vector<Image> images);

    Image convertToGray(Image img);

    Image convolutionGray(Image image, Image filter);

    Image thresholdBinary(Image image, int thresh);

    Image edgeDetection(Image image);

    Image getAbsoluteValue(Image image);

    Image findMinMaxLoc(Image image);

    Image scalePixels(Image image, int newHigh, int newLow);

    Image resizeImage(Image image, int newH, int newW);

    vector<Image> splitRGBChannels(Image image);

    Image addRGBChannels(Image r, Image g, Image b);

    Image cutImage(Image image, int beginY, int beginX, int endY, int endX);

    Image medianFilter(Image image, int h, int w);

    Image makeStructuralElement(int h, int type);

    Image morpDilation(Image image, int elementH, int elementType);

    Image morpErode(Image image, int elementH, int elementType);

    Image morpOpen(Image image, int elementH, int elementType);

    Image morpClose(Image image, int elementH, int elementType);

    Image makeNumber(int h, int w, int channel, float number1, float number2, float number3);

    Image histogramCalc(Image image);

    Image findColors(Image image);

    Image kmeansCluster(Image image, int k);

    Image smoothing(Image image, int filterH);

    Image clipImage(Image image);

    Image sharpening(Image image, int filterH);

    float otsuThresh(Image image);

    Image histogramEqual(Image image);

    Image laplacian(Image image);

    Image reverseImage(Image image);

    Image paintLabeledImage(Image image, int labelNum);

    Image connectedComponents(Image image);

}