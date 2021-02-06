#include<iostream>
#include<conio.h>
#include<cuda.h>
#include<ctime>
#include"pch.h"
#include<iomanip>
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp" 
#include"functions1.hpp"
#include"helper.cuh"
#include<queue>
using namespace std;
namespace imp {
    void printVec1d(float* vec, int h) {
        float x;
        for (int i = 0; i < h; i++) {
            //cout << fixed << setprecision(1) << " " << vec[i] << endl;
            x = vec[i];
            if (x < 10)
                cout << i << " --> " << fixed << setprecision(2) << setfill('0') << setw(3) << x << "   ";
            else if (x < 100)
                cout << i << " --> " << fixed << setprecision(2) << setfill('0') << setw(2) << x << "   ";
            else
                cout << i << " --> " << fixed << setprecision(2) << x << "   ";
            cout << endl;
        }
        cout << endl;
    }

    void printVec2d(float* mat1, int h, int w) {
        float x;
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                x = mat1[i * w + j];
                //cout << fixed << setprecision(1) << mat1[i * w + j] << "   ";
                if (x < 10)
                    cout << fixed << setprecision(2) << setfill('0') << setw(3) << x << "   ";
                else if (x < 100)
                    cout << fixed << setprecision(2) << setfill('0') << setw(2) << x << "   ";
                else
                    cout << fixed << setprecision(2) << x << "   ";

            }
            cout << endl;
        }
        cout << endl;
    }
    void printVec3d(float* mat1, int h, int w) {
        float x;
        int id;
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                for (int k = 0; k < 3; k++) {
                    //cout << fixed << setprecision(1) << mat1[(i * w + j) * 3 + k] << " ";
                    id = (i * w + j) * 3 + k;
                    x = mat1[id];
                    if (x < 10)
                        //<< id << " --> " 
                        cout << fixed << setprecision(2) << setfill('0') << setw(3) << x << "   ";
                    else if (x < 100)
                        cout << fixed << setprecision(2) << setfill('0') << setw(2) << x << "   ";
                    else
                        cout << fixed << setprecision(2) << x << "   ";
                }
                cout << "  ";
            }
            cout << endl;
        }
        cout << endl;
    }

    void printVec(float* mat1, int h, int w, int channel) {
        //channel == 0 1 dimention
        if (channel == 0)
            printVec1d(mat1, h);
        if (channel == 1)
            printVec2d(mat1, h, w);
        if (channel == 3)
            printVec3d(mat1, h, w);
        cout << endl;
    }

    void printImage(Image image) {
        int h = image.height, w = image.width, channel = image.channel;
        //channel == 0 1 dimention
        if (channel == 0)
            printVec1d(image.data, h);
        if (channel == 1)
            printVec2d(image.data, h, w);
        if (channel == 3)
            printVec3d(image.data, h, w);
        cout << endl;
    }

    void printHistogram(Image hist) {
        int h = 256, w = hist.width, id;
        float x;

        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                id = i * w + j;
                x = hist.data[id];
                if (x < 10)
                    cout << i << "," << j << " --> " << fixed << setprecision(2) << setfill('0') << setw(3) << x << "   ";
                else if (x < 100)
                    cout << i << "," << j << " --> " << fixed << setprecision(2) << setfill('0') << setw(2) << x << "   ";
                else
                    cout << i << "," << j << " --> " << fixed << setprecision(2) << x << "   ";

            }
            cout << endl;
        }
        cout << endl;

    }

    int* outputSizeCalc(int row, int col, int filterRow, int filterCol, int strideRow, int strideCol) {
        int newSizes[2];
        newSizes[0] = ((float)(row - filterRow) / (float)strideRow) + 1.0;
        newSizes[1] = ((float)(col - filterCol) / (float)strideCol) + 1.0;
        return newSizes;
    }

    Image matToImage(Mat image) {
        int r = image.rows, c = image.cols, ch = image.channels();
        Image im(r, c, ch);

        if (ch == 1) {
            //if(image.type()==0)
            uchar px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px = image.at<uchar>(i, j);
                    //*(newImage + i * c + j) = (float)px;
                    im.data[i * c + j] = (float)px;
                }
            }
        }
        else if (ch == 3) {
            Vec3b px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px = image.at<Vec3b>(i, j);
                    /**(newImage + (i * c + j) * 3 + 0) = (float)px[0];
                    *(newImage + (i * c + j) * 3 + 1) = (float)px[1];
                    *(newImage + (i * c + j) * 3 + 2) = (float)px[2];*/
                    im.data[(i * c + j) * 3 + 0] = (float)px[0];
                    im.data[(i * c + j) * 3 + 1] = (float)px[1];
                    im.data[(i * c + j) * 3 + 2] = (float)px[2];
                }
            }
        }
        return im;
    }

    Mat imageToMat(Image newImage) {
        int r = newImage.height, c = newImage.width, ch = newImage.channel;
        Mat image;
        if (ch == 1) {
            //if(image.type()==0)
            image = Mat(r, c, CV_8UC1);
            uchar px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px = (uchar)newImage.data[i * c + j];
                    image.at<uchar>(i, j) = px;
                }
            }
        }
        else if (ch == 3) {
            image = Mat(r, c, CV_8UC3);
            Vec3b px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px[0] = (uchar)newImage.data[(i * c + j) * 3 + 0];
                    px[1] = (uchar)newImage.data[(i * c + j) * 3 + 1];
                    px[2] = (uchar)newImage.data[(i * c + j) * 3 + 2];
                    image.at<Vec3b>(i, j) = px;
                }
            }
        }

        return image;
    }

    float* matToFloat(Mat image) {
        int r = image.rows, c = image.cols, ch = image.channels();
        float* newImage = (float*)malloc(sizeof(float) * r * c * ch);

        if (ch == 1) {
            //if(image.type()==0)
            uchar px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px = image.at<uchar>(i, j);
                    //*(newImage + i * c + j) = (float)px;
                    newImage[i * c + j] = (float)px;
                }
            }
        }
        else if (ch == 3) {
            Vec3b px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    px = image.at<Vec3b>(i, j);
                    /**(newImage + (i * c + j) * 3 + 0) = (float)px[0];
                    *(newImage + (i * c + j) * 3 + 1) = (float)px[1];
                    *(newImage + (i * c + j) * 3 + 2) = (float)px[2];*/
                    newImage[(i * c + j) * 3 + 0] = (float)px[0];
                    newImage[(i * c + j) * 3 + 1] = (float)px[1];
                    newImage[(i * c + j) * 3 + 2] = (float)px[2];
                }
            }
        }
        return newImage;

    }

    Mat floatToMat(float* newImage, int r, int c, int ch) {
        Mat image;

        if (ch == 1) {
            //if(image.type()==0)
            image = Mat(r, c, CV_8UC1);
            uchar px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    //px = (uchar) *(newImage + i * c + j);
                    px = (uchar)newImage[i * c + j];
                    image.at<uchar>(i, j) = px;
                }
            }
        }
        else if (ch == 3) {
            image = Mat(r, c, CV_8UC3);
            Vec3b px;
            for (int i = 0; i < r; i++) {
                for (int j = 0; j < c; j++) {
                    /*px[0] = (uchar) * (newImage + (i * c + j) * 3 + 0);
                    px[1] = (uchar) * (newImage + (i * c + j) * 3 + 1);
                    px[2] = (uchar) * (newImage + (i * c + j) * 3 + 2);*/
                    px[0] = (uchar)newImage[(i * c + j) * 3 + 0];
                    px[1] = (uchar)newImage[(i * c + j) * 3 + 1];
                    px[2] = (uchar)newImage[(i * c + j) * 3 + 2];
                    image.at<Vec3b>(i, j) = px;
                }
            }
        }

        return image;
    }

    Image readImage(string path) {
        Mat img = imread(path);
        return matToImage(img);
    }

    Image readImage(const char path[]) {
        Mat img = imread(path);
        return matToImage(img);
    }

    Image readImage(string path, int h, int w) {
        Mat img = imread(path);
        resize(img, img, Size(w, h));//kendi fonk ile degistir!!
        return matToImage(img);
    }

    Image readImage(const char path[], int h, int w) {
        Mat img = imread(path);
        resize(img, img, Size(w, h));//kendi fonk ile degistir!!
        return matToImage(img);
    }

    void writeImage(Image image, string path) {
        Mat m = imageToMat(image);
        imwrite(path, m);
    }

    void writeImage(Image image, const char path[]) {
        Mat m = imageToMat(image);
        imwrite(path, m);
    }

    void showImage(Image image) {
        Mat img = floatToMat(image.data, image.height, image.width, image.channel);
        imshow("image", img);
        waitKey(0);
    }

    void showImages(vector<Image> images) {
        Mat img;
        int i = 0;
        for (Image im : images) {
            img = floatToMat(im.data, im.height, im.width, im.channel);
            imshow(to_string(i), img);
            ++i;
        }
        waitKey(0);
    }

    Image convertToGray(Image img) {
        if (img.channel == 3) {
            Image output(img.height, img.width, 1);
            convertToGrayCuda(img.data, img.height, img.width, output.data);
            return output;
        }
        return img;
    }

    Image convolutionGray(Image image, Image filter) {//stride degistirilebilsin
        int padRow = 0, padCol = 0, strideRow = 1, strideCol = 1;
        int row = image.height, col = image.width;
        int filterRow = filter.height, filterCol = filter.width;

        int* outputSizes = outputSizeCalc(row, col, filterRow, filterCol, strideRow, strideCol);
        int outputRow = outputSizes[0], outputCol = outputSizes[1];
        Image gray(outputRow, outputCol, 1);
        //gray.data = convolutionCuda(image.data, filter.data, row, col, filterRow, filterCol, strideRow, strideCol,gray.data, gray.height, gray.width);
        convolutionCuda(image.data, filter.data, row, col, filterRow, filterCol, strideRow, strideCol, gray.data, gray.height, gray.width);
        return gray;
    }

    Image thresholdBinary(Image image, int thresh) {
        if (image.channel == 1) {
            Image bw(image.height, image.width, image.channel);
            thresholdCuda(image.data, bw.data, thresh, image.height, image.width);
            return bw;
        }
        return image;
    }

    Image edgeDetection(Image image) {
        if (image.channel == 1) {
            Image i1, i2, f1;
            f1.makeHorizontalPrewittFilter();
            i1 = convolutionGray(image, f1);
            f1.makeVerticalPrewittFilter();
            i2 = convolutionGray(image, f1);
            Image o1(i1.height, i1.width, i1.channel);
            //showImages(vector<Image>{i1,i2});//sikinti var resimlerde,absolute falan al duzelt
            prewittAddCuda(i1.data, i2.data, o1.data, i1.height, i1.width);
            return o1;
        }
        return image;
    }

    Image getAbsoluteValue(Image image) {
        Image o1(image.height, image.width, image.channel);
        absoluteValueCuda(image.data, o1.data, image.height, image.width);
        return o1;
    }

    Image findMinMaxLoc(Image image) {
        int h = image.height, w = image.width;
        float min = image.data[0], max = image.data[0];
        float minX = 0, minY = 0, maxX = 0, maxY = 0;
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                if (image.data[i * w + j] > max) {
                    max = image.data[i * w + j];
                    maxY = i;
                    maxX = j;
                }
                if (image.data[i * w + j] < min) {
                    min = image.data[i * w + j];
                    minY = i;
                    minX = j;
                }
            }
        }

        Image minMaxLoc(1, 6, 1);
        minMaxLoc.data[0] = min;
        minMaxLoc.data[1] = minY;
        minMaxLoc.data[2] = minX;
        minMaxLoc.data[3] = max;
        minMaxLoc.data[4] = maxY;
        minMaxLoc.data[5] = maxX;

        return minMaxLoc;
    }

    Image scalePixels(Image image, int newHigh, int newLow) {
        Image minMaxLoc = findMinMaxLoc(image);
        float min, max, minY, minX, maxX, maxY, diff;
        min = minMaxLoc.data[0];
        minY = minMaxLoc.data[1];
        minX = minMaxLoc.data[2];
        max = minMaxLoc.data[3];
        maxY = minMaxLoc.data[4];
        maxX = minMaxLoc.data[5];
        diff = max - min;

        Image output(image.height, image.width, image.channel);
        scalePixelsCuda(image.data, output.data, image.height, image.width, diff, min, newHigh, newLow);
        return output;
    }

    Image resizeImage(Image image, int newH, int newW) {
        if (image.channel == 1) {
            Image output(newH, newW, 1);
            resizeImageCuda(image.data, output.data, image.height, image.width, output.height, output.width, image.channel);
            return output;
        }
        else if (image.channel == 3) {
            Image output(newH, newW, 3);
            resizeImageCuda(image.data, output.data, image.height, image.width, output.height, output.width, image.channel);
            return output;
        }
        return image;
    }

    vector<Image> splitRGBChannels(Image image) {
        Image r(image.height, image.width, 1), g(image.height, image.width, 1), b(image.height, image.width, 1);
        splitRGBChannelsCuda(image.data, r.data, g.data, b.data, image.height, image.width);
        return vector<Image>{r, g, b};
    }

    Image addRGBChannels(Image r, Image g, Image b) {
        Image inputImage(r.height, r.width, 3);
        addRGBChannelsCuda(inputImage.data, r.data, g.data, b.data, r.height, r.width);
        return inputImage;
    }

    Image cutImage(Image image, int beginY, int beginX, int endY, int endX) {
        if (beginY >= 0 && endY > beginY&& endY <= image.height && beginX >= 0 && endX > beginX&& endX <= image.width) {
            Image outputImage(endY - beginY, endX - beginX, image.channel);
            cutImageCuda(image.data, outputImage.data, image.height, image.width, beginY, beginX, endY, endX, image.channel);
            return outputImage;
        }
        //return Image();
        return image;
    }

    Image medianFilter(Image image, int filterRow, int filterCol) {
        int padRow = 0, padCol = 0, strideRow = 1, strideCol = 1;
        int* outputSizes = outputSizeCalc(image.height, image.width, filterRow, filterCol, strideRow, strideCol);
        int outputRow = outputSizes[0], outputCol = outputSizes[1];
        Image outputImage(outputRow, outputCol, 1);
        medianFilterCuda(image.data, image.height, image.width, filterRow, filterCol, strideRow, strideCol, outputImage.data, outputRow, outputCol);
        return outputImage;
    }

    Image makeStructuralElement(int h, int type) {//h -> odd number
        //type 0 == square; 1 == plus; 2 == vertical; 3 == horizontal
        if (type < 0 || type>3)
            type = 0;
        if (h < 3)
            h = 3;
        if (h % 2 == 0)
            h++;

        int w = h;
        int hH = h / 2, wH = w / 2;
        Image element(h, w, 1);

        if (type == 0) {
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    element.data[i * w + j] = 255;
                }
            }
        }
        else if (type == 1) {
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    if (i == hH || j == wH) {
                        element.data[i * w + j] = 255;
                    }
                    else {
                        element.data[i * w + j] = 0;
                    }
                }
            }
        }
        else if (type == 2) {
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    if (j == wH) {
                        element.data[i * w + j] = 255;
                    }
                    else {
                        element.data[i * w + j] = 0;
                    }
                }
            }
        }
        else if (type == 3) {
            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    if (i == hH) {
                        element.data[i * w + j] = 255;
                    }
                    else {
                        element.data[i * w + j] = 0;
                    }
                }
            }
        }
        return element;
    }

    Image morpDilation(Image image, int elementH, int elementType) {
        if (image.channel == 1) {
            Image sElement = makeStructuralElement(elementH, elementType);
            Image output(image.height, image.width, 1);
            dilateCuda(image.data, image.height, image.width, sElement.data, sElement.height, sElement.width, output.data);
            return output;
        }
        return image;
    }

    Image morpErode(Image image, int elementH, int elementType) {
        if (image.channel == 1) {
            Image sElement = makeStructuralElement(elementH, elementType);
            Image output(image.height, image.width, 1);
            erodeCuda(image.data, image.height, image.width, sElement.data, sElement.height, sElement.width, output.data);
            return output;
        }
        return image;
    }

    Image morpOpen(Image image, int elementH, int elementType) {
        if (image.channel == 1) {
            Image sElement = makeStructuralElement(elementH, elementType);
            Image output(image.height, image.width, 1);
            erodeCuda(image.data, image.height, image.width, sElement.data, sElement.height, sElement.width, output.data);
            Image output2(image.height, image.width, 1);
            dilateCuda(output.data, output.height, output.width, sElement.data, sElement.height, sElement.width, output2.data);
            return output2;
        }
        return image;
    }

    Image morpClose(Image image, int elementH, int elementType) {
        if (image.channel == 1) {
            Image sElement = makeStructuralElement(elementH, elementType);
            Image output(image.height, image.width, 1);
            dilateCuda(image.data, image.height, image.width, sElement.data, sElement.height, sElement.width, output.data);
            Image output2(image.height, image.width, 1);
            erodeCuda(output.data, output.height, output.width, sElement.data, sElement.height, sElement.width, output2.data);
            return output2;
        }
        return image;
    }

    Image makeNumber(int h, int w, int channel, float number1, float number2, float number3) {
        Image output(h, w, channel);
        makeNumberCuda(output.data, h, w, channel, number1, number2, number3);
        return output;
    }

    Image histogramCalc(Image image) {
        Image histogram = makeNumber(256, image.channel, 1, 0, 0, 0);
        histogramCuda(image.data, image.height, image.width, image.channel, histogram.data);
        return histogram;
    }

    Image findColors(Image image) {
        /*float* output;
        int *h=(int*)malloc(sizeof(int));
        output = compareRGBColorsCuda(image.data, image.height, image.width, h);
        Image outputImage(h[0], 3, 1);
        outputImage.data = output;
        return outputImage;*/

        /*bool* exist = (bool*)malloc(sizeof(bool) * image.height * image.width);
        int* h = (int*)malloc(sizeof(int));
        exist = compareRGBColorsCuda(image.data, image.height, image.width, h);
        float* colors = (float*)malloc(sizeof(float) * h[0] * 3);
        int id = 0;
        for (int i = 0; i < image.height * image.width; i++) {
            if (exist[i] == true) {
                colors[id * 3 + 0] = image.data[i * 3 + 0];
                colors[id * 3 + 1] = image.data[i * 3 + 1];
                colors[id * 3 + 2] = image.data[i * 3 + 2];
                id++;
            }
        }
        Image outputImage(h[0], 3, 1);
        outputImage.data = colors;
        return outputImage;*/

        bool exist = false;
        float r, g, b;
        int colorNumber = 0;
        Image colors(image.height * image.width, 3, 1);
        for (int i = 0; i < image.height; i++) {
            for (int j = 0; j < image.width; j++) {
                exist = false;
                r = image.data[(i * image.width + j) * 3 + 0];
                g = image.data[(i * image.width + j) * 3 + 1];
                b = image.data[(i * image.width + j) * 3 + 2];
                for (int cn = 0; cn < colorNumber; cn++) {
                    /*cout << colors.data[colorNumber * 3 + 0] << " "<<colors.data[colorNumber * 3 + 1] << " "<<colors.data[colorNumber * 3 + 2] << endl;
                    cout << r<<" "<<g<<" "<<b<<endl;*/
                    if (colors.data[cn * 3 + 0] == r && colors.data[cn * 3 + 1] == g && colors.data[cn * 3 + 2] == b) {
                        exist = true;
                        break;
                    }
                }
                if (exist == false) {
                    colors.data[colorNumber * 3 + 0] = r;
                    colors.data[colorNumber * 3 + 1] = g;
                    colors.data[colorNumber * 3 + 2] = b;
                    colorNumber += 1;
                }
            }
        }
        Image output = cutImage(colors, 0, 0, colorNumber, 3);
        /*cout << colorNumber << endl;
        output.printSize();
        printImage(output);*/
        return output;
    }

    Image kmeansCluster(Image image, int k) {
        bool resize = false;
        //int newH = 300, newW = 300;
        int newH = 1000, newW = 1000;
        int oldH = image.height, oldW = image.width;
        if (k > 1) {
            if (image.height > newH || image.width > newW) {
                resize = true;
                image = resizeImage(image, newH, newW);
            }
            Image output(image.height, image.width, image.channel);
            if (image.channel == 1)
                kmeansGrayCuda(image.data, image.height, image.width, output.data, k);
            else if (image.channel == 3) {
                /*Image colors = findColors(image);
                if (colors.height < k)
                    return image;
                kmeansRGBCuda(image.data, image.height, image.width, output.data, k, colors.data, colors.height);
            */
                return image;
            }
            if (resize) {
                output = resizeImage(output, oldH, oldW);
            }
            return output;
        }
        return image;
    }

    Image smoothing(Image image, int filterH) {
        if (filterH < 3)
            filterH = 3;
        if (filterH % 2 == 0)
            filterH++;
        Image filter; filter.makeMeanFilter(filterH, filterH);

        if (image.channel == 1) {
            Image output = convolutionGray(image, filter);
            return output;
        }
        else if (image.channel == 3) {
            vector<Image> rgb = splitRGBChannels(image);
            Image output1 = convolutionGray(rgb[0], filter);
            Image output2 = convolutionGray(rgb[1], filter);
            Image output3 = convolutionGray(rgb[2], filter);
            Image output = addRGBChannels(output1, output2, output3);
            return output;
        }

    }

    Image clipImage(Image image) {
        int low = 0, high = 255;
        Image output(image.height, image.width, image.channel);
        clipImagesCuda(image.data, output.data, image.height, image.width, image.channel, low, high);
        return output;
    }

    Image sharpening(Image image, int filterH) {
        if (image.channel == 1) {
            float alpha = 1, beta = 1;
            Image smooth = smoothing(image, filterH);
            smooth = resizeImage(smooth, image.height, image.width);
            Image output(image.height, image.width, image.channel);
            subtractImagesCuda(image.data, smooth.data, output.data, image.height, image.width, image.channel);
            output = getAbsoluteValue(output);
            output = clipImage(output);
            addImagesCuda(image.data, output.data, smooth.data, image.height, image.width, alpha, beta, image.channel);
            smooth = clipImage(smooth);
            //smooth=scalePixels(smooth, 255, 0);
            return smooth;
        }
        else {
            return image;
        }
    }

    float otsuThresh(Image image) {
        if (image.channel == 1)
            return otsuCuda(image.data, image.height, image.width);
        return 1;
    }

    Image histogramEqual(Image image) {
        Image output(image.height, image.width, image.channel);
        if (image.channel == 1) {
            histEqualCuda(image.data, image.height, image.width, output.data);
            return output;
        }
        return image;
    }

    Image laplacian(Image image) {
        if (image.channel == 1) {
            Image filter; filter.makeLaplaceFilter();
            Image output = convolutionGray(image, filter);
            output = getAbsoluteValue(output);
            return output;
        }
        return image;
    }

    Image reverseImage(Image image) {
        if (image.channel == 1) {
            Image output(image.height, image.width, 1);
            reverseImageCuda(image.data, output.data, image.height, image.width);
            return output;
        }
        return image;
    }

    Image paintLabeledImage(Image image, int labelNum) {
        int h = image.height, w = image.width, x;
        Image output = makeNumber(image.height, image.width, 3, 0, 0, 0);
        float* colors = (float*)malloc(sizeof(float) * labelNum * 3);
        for (int i = 0; i < labelNum; i++) {
            colors[i * 3 + 0] = rand() % 255;
            colors[i * 3 + 1] = rand() % 255;
            colors[i * 3 + 2] = rand() % 255;
        }
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < w; j++) {
                x = image.data[i * w + j] - 1;
                output.data[(i * w + j) * 3 + 0] = colors[x * 3 + 0];
                output.data[(i * w + j) * 3 + 1] = colors[x * 3 + 1];
                output.data[(i * w + j) * 3 + 2] = colors[x * 3 + 2];
            }
        }
        return output;
    }

    Image connectedComponents(Image image) {
        //4 connectivity
        if (image.channel == 1) {
            Image output = makeNumber(image.height, image.width, 1, 0, 0, 0);
            //cuda
            int label = 0, h = image.height, w = image.width, y, x, qSize;
            queue<int> xs, ys;

            for (int i = 0; i < h; i++) {
                for (int j = 0; j < w; j++) {
                    if (image.data[i * w + j] != 0 && output.data[i * w + j] == 0) {
                        label++;
                        output.data[i * w + j] = label;
                        ys.push(i);
                        xs.push(j);
                        qSize = xs.size();
                        while (qSize != 0) {
                            y = ys.front();
                            ys.pop();
                            x = xs.front();
                            xs.pop();
                            if (y - 1 > 0 && image.data[(y - 1) * w + x] != 0 && output.data[(y - 1) * w + x] == 0) {//up
                                output.data[(y - 1) * w + x] = label;
                                ys.push(y - 1);
                                xs.push(x);
                            }
                            if (y + 1 < h && image.data[(y + 1) * w + x] != 0 && output.data[(y + 1) * w + x] == 0) {//down
                                output.data[(y + 1) * w + x] = label;
                                ys.push(y + 1);
                                xs.push(x);
                            }
                            if (x - 1 > 0 && image.data[y * w + (x - 1)] != 0 && output.data[y * w + (x - 1)] == 0) {//left
                                output.data[y * w + (x - 1)] = label;
                                ys.push(y);
                                xs.push(x - 1);
                            }
                            if (x + 1 < w && image.data[y * w + (x + 1)] != 0 && output.data[y * w + (x + 1)] == 0) {//right
                                output.data[y * w + (x + 1)] = label;
                                ys.push(y);
                                xs.push(x + 1);
                            }
                            qSize = xs.size();
                        }
                    }
                }
            }
            return paintLabeledImage(output, label);
        }
        return image;
    }
}