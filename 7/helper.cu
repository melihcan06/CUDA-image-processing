#include<iostream>
#include<conio.h>
#include<cuda.h>
#include<ctime>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>
#include<device_functions.h>
#include<iomanip>

#include "helper.cuh"

//using namespace std;//sil

__global__ void convolutionKernel(float* inputImage, float* filter, float* outputImage, int* filterSize, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int fH = filterSize[0];
		int fW = filterSize[1];
		int outputIdx = r * outputWidth + c;
		int inputBeginX = c * strideCol;//kontrol et!!!
		int inputBeginY = r * strideRow;//kontrol et!!!

		int  fi = 0, fj = 0;
		float sum = 0;
		for (int i = inputBeginY; i < inputBeginY + fH; i++) {
			fj = 0;
			for (int j = inputBeginX; j < inputBeginX + fW; j++) {
				sum += inputImage[i * inputWidth + j] * filter[fi * fW + fj];
				fj++;
			}
			fi++;
		}
		outputImage[outputIdx] = sum;
	}
}

//float*
void convolutionCuda(float* inputImage, float* filter, int inputRow, int inputCol, int filterRow, int filterCol, int strideRow, int strideCol, float* outputImage, int outputRow, int outputCol) {
	int filterSize[] = { filterRow, filterCol };
	float* inputCuda, * filterCuda, * outputCuda;
	int* filterSizeCuda;

	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&filterCuda, sizeof(float) * filterRow * filterCol);
	cudaMemcpy(filterCuda, filter, sizeof(float) * filterRow * filterCol, cudaMemcpyHostToDevice);
	cudaMalloc(&filterSizeCuda, sizeof(int) * 2);
	cudaMemcpy(filterSizeCuda, filterSize, sizeof(int) * 2, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputRow * outputCol);

	dim3 gridDim(outputCol, outputRow, 1);
	convolutionKernel << <gridDim, 1 >> > (inputCuda, filterCuda, outputCuda, filterSizeCuda, inputCol, outputCol, outputRow, strideRow, strideCol);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputRow * outputCol, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(filterCuda);
	cudaFree(filterSizeCuda);
	cudaFree(outputCuda);

	//return outputImage;
}

__global__ void  convertToGrayKernel(float* inputImage, float* outputImage, int outputWidth, int outputHeight) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int inputRIdx = (r * outputWidth + c) * 3 + 0;
		int inputGIdx = (r * outputWidth + c) * 3 + 1;
		int inputBIdx = (r * outputWidth + c) * 3 + 2;

		outputImage[r * outputWidth + c] = (inputImage[inputRIdx] + inputImage[inputGIdx] + inputImage[inputBIdx]) / 3.0;
	}
}

//float*
void convertToGrayCuda(float* inputImage, int inputRow, int inputCol, float* outputImage) {
	int outputRow = inputRow, outputCol = inputCol;
	//float* outputImage = (float*)malloc(sizeof(float) * outputRow * outputCol);
	float* inputCuda, * outputCuda;

	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * 3);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * 3, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputRow * outputCol);

	dim3 gridDim(outputCol, outputRow, 1);
	convertToGrayKernel << <gridDim, 1 >> > (inputCuda, outputCuda, outputCol, outputRow);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputRow * outputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);

	//return outputImage;
}



__global__ void thresholdKernel(float* inputImage, float* outputImage, int thresh, int outputWidth, int outputHeight) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		if (inputImage[r * outputWidth + c] >= thresh) {
			outputImage[r * outputWidth + c] = 255;
		}
		else {
			outputImage[r * outputWidth + c] = 0;
		}
	}
}
void thresholdCuda(float* inputImage, float* outputImage, int thresh, int inputRow, int inputCol) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(inputCol, inputRow, 1);
	thresholdKernel << <gridDim, 1 >> > (inputCuda, outputCuda, thresh, inputCol, inputRow);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);

	//return outputImage;
}

__global__ void prewittAddKernel(float* inputImage1, float* inputImage2, float* outputImage, int outputHeight, int outputWidth) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		outputImage[r * outputWidth + c] = sqrt(inputImage1[r * outputWidth + c] * inputImage1[r * outputWidth + c] + inputImage2[r * outputWidth + c] * inputImage2[r * outputWidth + c]);
	}
}
void prewittAddCuda(float* inputImage1, float* inputImage2, float* outputImage, int inputRow, int inputCol) {
	float* inputCuda1, * inputCuda2, * outputCuda;
	cudaMalloc(&inputCuda1, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda1, inputImage1, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&inputCuda2, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda2, inputImage2, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(inputCol, inputRow, 1);
	prewittAddKernel << <gridDim, 1 >> > (inputCuda1, inputCuda2, outputCuda, inputRow, inputCol);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda1);
	cudaFree(inputCuda2);
	cudaFree(outputCuda);
}
__global__ void absoluteValueKernel(float* inputImage, float* outputImage, int outputHeight, int outputWidth) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		if (inputImage[r * outputWidth + c] >= 0)
			outputImage[r * outputWidth + c] = inputImage[r * outputWidth + c];
		else
			outputImage[r * outputWidth + c] = -inputImage[r * outputWidth + c];
	}
}

void absoluteValueCuda(float* inputImage, float* outputImage, int inputRow, int inputCol) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(inputCol, inputRow, 1);
	absoluteValueKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputRow, inputCol);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}
__global__ void addArrayKernel(float* inputImage, float* sum, int outputHeight, int outputWidth) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		atomicAdd(sum, inputImage[r * outputWidth + c]);
		//sum[0] += inputImage[r * outputWidth + c];
	}
}

int addArrayCuda(float* inputImage, int outputHeight, int outputWidth) {
	float* outputImage = (float*)malloc(sizeof(float) * 1);
	outputImage[0] = 0;

	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * outputHeight * outputWidth);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * outputHeight * outputWidth, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * 1);
	cudaMemcpy(outputCuda, outputImage, sizeof(float) * 1, cudaMemcpyHostToDevice);

	dim3 gridDim(outputWidth, outputHeight, 1);
	addArrayKernel << <gridDim, 1 >> > (inputCuda, outputCuda, outputHeight, outputWidth);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * 1, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);

	return outputImage[0];
}

__global__ void scalePixelsKernel(float* inputImage, float* outputImage, int outputHeight, int outputWidth, float diff, float min, float newHigh, float newLow) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		outputImage[r * outputWidth + c] = ((inputImage[r * outputWidth + c] - min) / diff) * newHigh + newLow;
	}
}

void scalePixelsCuda(float* inputImage, float* outputImage, int outputHeight, int outputWidth, float diff, float min, float newHigh, float newLow) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * outputHeight * outputWidth);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * outputHeight * outputWidth, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputHeight * outputWidth);

	dim3 gridDim(outputWidth, outputHeight, 1);
	scalePixelsKernel << <gridDim, 1 >> > (inputCuda, outputCuda, outputHeight, outputWidth, diff, min, newHigh, newLow);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputHeight * outputWidth, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}

__global__ void resizeGrayImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth) {
	//int(x_indis*eski_boyut_x/yeni_boyut_x),int(y_indis*eski_boyut_y / yeni_boyut_y)
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int x = (float)(c * inputWidth) / (float)outputWidth;
		int y = (float)(r * inputHeight) / (float)outputHeight;
		outputImage[r * outputWidth + c] = inputImage[y * inputWidth + x];
	}
}

__global__ void resizeRGBImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth) {
	//int(x_indis*eski_boyut_x/yeni_boyut_x),int(y_indis*eski_boyut_y / yeni_boyut_y)
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int x = (float)(c * inputWidth) / (float)outputWidth;
		int y = (float)(r * inputHeight) / (float)outputHeight;
		outputImage[(r * outputWidth + c) * 3 + 0] = inputImage[(y * inputWidth + x) * 3 + 0];
		outputImage[(r * outputWidth + c) * 3 + 1] = inputImage[(y * inputWidth + x) * 3 + 1];
		outputImage[(r * outputWidth + c) * 3 + 2] = inputImage[(y * inputWidth + x) * 3 + 2];
	}
}

void resizeImageCuda(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int outputHeight, int outputWidth, int channel) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputHeight * inputWidth * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputHeight * inputWidth * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputHeight * outputWidth * channel);

	dim3 gridDim(outputWidth, outputHeight, 1);
	if (channel == 1)
		resizeGrayImageKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputHeight, inputWidth, outputHeight, outputWidth);
	else if (channel == 3)
		resizeRGBImageKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputHeight, inputWidth, outputHeight, outputWidth);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputHeight * outputWidth * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}

__global__ void splitRGBChannelsKernel(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputWidth && r < inputHeight) {
		rImage[r * inputWidth + c] = inputImage[(r * inputWidth + c) * 3 + 0];
		gImage[r * inputWidth + c] = inputImage[(r * inputWidth + c) * 3 + 1];
		bImage[r * inputWidth + c] = inputImage[(r * inputWidth + c) * 3 + 2];
	}
}

void splitRGBChannelsCuda(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth) {
	float* inputCuda, * rCuda, * gCuda, * bCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputHeight * inputWidth * 3);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputHeight * inputWidth * 3, cudaMemcpyHostToDevice);
	cudaMalloc(&rCuda, sizeof(float) * inputHeight * inputWidth);
	cudaMalloc(&gCuda, sizeof(float) * inputHeight * inputWidth);
	cudaMalloc(&bCuda, sizeof(float) * inputHeight * inputWidth);

	dim3 gridDim(inputWidth, inputHeight, 1);
	splitRGBChannelsKernel << <gridDim, 1 >> > (inputCuda, rCuda, gCuda, bCuda, inputHeight, inputWidth);

	cudaMemcpy(rImage, rCuda, sizeof(float) * inputHeight * inputWidth, cudaMemcpyDeviceToHost);
	cudaMemcpy(gImage, gCuda, sizeof(float) * inputHeight * inputWidth, cudaMemcpyDeviceToHost);
	cudaMemcpy(bImage, bCuda, sizeof(float) * inputHeight * inputWidth, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(rCuda);
	cudaFree(gCuda);
	cudaFree(bCuda);
}

__global__ void addRGBChannelsKernel(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputWidth && r < inputHeight) {
		inputImage[(r * inputWidth + c) * 3 + 0] = rImage[r * inputWidth + c];
		inputImage[(r * inputWidth + c) * 3 + 1] = gImage[r * inputWidth + c];
		inputImage[(r * inputWidth + c) * 3 + 2] = bImage[r * inputWidth + c];
	}
}

void addRGBChannelsCuda(float* inputImage, float* rImage, float* gImage, float* bImage, int inputHeight, int inputWidth) {
	float* inputCuda, * rCuda, * gCuda, * bCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputHeight * inputWidth * 3);
	cudaMalloc(&rCuda, sizeof(float) * inputHeight * inputWidth);
	cudaMemcpy(rCuda, rImage, sizeof(float) * inputHeight * inputWidth, cudaMemcpyHostToDevice);
	cudaMalloc(&gCuda, sizeof(float) * inputHeight * inputWidth);
	cudaMemcpy(gCuda, gImage, sizeof(float) * inputHeight * inputWidth, cudaMemcpyHostToDevice);
	cudaMalloc(&bCuda, sizeof(float) * inputHeight * inputWidth);
	cudaMemcpy(bCuda, bImage, sizeof(float) * inputHeight * inputWidth, cudaMemcpyHostToDevice);

	dim3 gridDim(inputWidth, inputHeight, 1);
	addRGBChannelsKernel << <gridDim, 1 >> > (inputCuda, rCuda, gCuda, bCuda, inputHeight, inputWidth);

	cudaMemcpy(inputImage, inputCuda, sizeof(float) * inputHeight * inputWidth * 3, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(rCuda);
	cudaFree(gCuda);
	cudaFree(bCuda);
}

__global__ void cutGrayImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputWidth && r < inputHeight && c < endX && c >= beginX && r < endY && r >= beginY) {
		int x = c - beginX, y = r - beginY, outputWidth = endX - beginX;
		outputImage[y * outputWidth + x] = inputImage[r * inputWidth + c];
	}
}

__global__ void cutRGBImageKernel(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputWidth && r < inputHeight && c < endX && c >= beginX && r < endY && r >= beginY) {
		int x = c - beginX, y = r - beginY, outputWidth = endX - beginX;
		outputImage[(y * outputWidth + x) * 3 + 0] = inputImage[(r * inputWidth + c) * 3 + 0];
		outputImage[(y * outputWidth + x) * 3 + 1] = inputImage[(r * inputWidth + c) * 3 + 1];
		outputImage[(y * outputWidth + x) * 3 + 2] = inputImage[(r * inputWidth + c) * 3 + 2];
	}
}

void cutImageCuda(float* inputImage, float* outputImage, int inputHeight, int inputWidth, int beginY, int beginX, int endY, int endX, int channel) {
	int outputHeight = endY - beginY, outputWidth = endX - beginX;
	float* inputCuda, * outputCuda;
	dim3 gridDim(inputWidth, inputHeight, 1);
	cudaMalloc(&inputCuda, sizeof(float) * inputHeight * inputWidth * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputHeight * inputWidth * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputHeight * outputWidth * channel);
	if (channel == 1) {
		cutGrayImageKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputHeight, inputWidth, beginY, beginX, endY, endX);
	}
	else if (channel == 3) {
		cutRGBImageKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputHeight, inputWidth, beginY, beginX, endY, endX);
	}
	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputHeight * outputWidth * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}
__global__ void medianFilterMapKernel(float* inputImage, float* map, int fH, int fW, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int outputIdx = r * outputWidth + c;

		int inputBeginX = c * strideCol;//kontrol et!!!
		int inputBeginY = r * strideRow;//kontrol et!!!				

		int  fi = 0, mWidth = fH * fW;
		for (int i = inputBeginY; i < inputBeginY + fH; i++) {
			for (int j = inputBeginX; j < inputBeginX + fW; j++) {
				map[outputIdx * mWidth + fi] = inputImage[i * inputWidth + j];
				fi++;
			}
		}
	}
}
__global__ void medianFilterSortKernel(float* inputImage, float* outputImage, float* map, int fH, int fW, int inputWidth, int outputWidth, int outputHeight, int strideRow, int strideCol) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < outputWidth && r < outputHeight) {
		int outputIdx = r * outputWidth + c;

		int inputBeginX = c * strideCol;//kontrol et!!!
		int inputBeginY = r * strideRow;//kontrol et!!!				

		int  mWidth = fH * fW;
		float temp;
		for (int i = 0; i < fH * fW - 1; i++) {
			for (int j = 0; j < fH * fW - i - 1; j++) {
				if (map[outputIdx * mWidth + j] > map[outputIdx * mWidth + j + 1]) {
					temp = map[outputIdx * mWidth + j + 1];
					map[outputIdx * mWidth + j + 1] = map[outputIdx * mWidth + j];
					map[outputIdx * mWidth + j] = temp;
				}
			}
		}

		int median = fW * fH / 2;
		outputImage[outputIdx] = map[outputIdx * mWidth + median];
	}
}

void medianFilterCuda(float* inputImage, int inputRow, int inputCol, int filterRow, int filterCol, int strideRow, int strideCol, float* outputImage, int outputRow, int outputCol) {
	float* inputCuda, * outputCuda, * mapCuda;

	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * outputRow * outputCol);
	cudaMalloc(&mapCuda, sizeof(float) * inputRow * inputCol * filterRow * filterCol);

	dim3 gridDim(outputCol, outputRow, 1);
	medianFilterMapKernel << <gridDim, 1 >> > (inputCuda, mapCuda, filterRow, filterCol, inputCol, outputCol, outputRow, strideRow, strideCol);
	medianFilterSortKernel << <gridDim, 1 >> > (inputCuda, outputCuda, mapCuda, filterRow, filterCol, inputCol, outputCol, outputRow, strideRow, strideCol);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * outputRow * outputCol, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(outputCuda);
	cudaFree(mapCuda);
}

__global__ void dilateKernel(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage) {
	int c = blockIdx.x, r = blockIdx.y;
	int idx = r * inputCol + c;
	if (c < inputCol && r < inputRow && inputImage[idx] == 255) {
		int fH2 = filterRow / 2, fW2 = filterCol / 2;
		if (r >= fH2 && c >= fW2 && r < inputRow - fH2 && c < inputCol - fW2) {
			int iterY = 0, iterX = 0;
			for (int i = r - fH2; i <= r + fH2; i++) {
				iterX = 0;
				for (int j = c - fW2; j <= c + fW2; j++) {
					if (filter[iterY * filterCol + iterX] == 255)
						outputImage[i * inputCol + j] = 255;
					iterX++;
				}
				iterY++;
			}
		}
	}
}

void dilateCuda(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage) {
	float* inputCuda, * outputCuda, * filterCuda;

	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&filterCuda, sizeof(float) * filterRow * filterCol);
	cudaMemcpy(filterCuda, filter, sizeof(float) * filterRow * filterCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(outputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);

	dim3 gridDim(inputCol, inputRow, 1);
	dilateKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, filterCuda, filterRow, filterCol, outputCuda);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(filterCuda);
	cudaFree(outputCuda);
}

__global__ void erodeKernel(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage) {
	int c = blockIdx.x, r = blockIdx.y;
	int idx = r * inputCol + c;
	if (c < inputCol && r < inputRow && inputImage[idx] == 255) {
		int fH2 = filterRow / 2, fW2 = filterCol / 2;
		if (r >= fH2 && c >= fW2 && r < inputRow - fH2 && c < inputCol - fW2) {
			bool same = true;
			int iterY = 0, iterX = 0;
			for (int i = r - fH2; i <= r + fH2; i++) {
				iterX = 0;
				for (int j = c - fW2; j <= c + fW2; j++) {
					if (filter[iterY * filterCol + iterX] == 255 && inputImage[i * inputCol + j] == 0) {
						same = false;
						break;
					}
					if (same != true) {
						break;
					}
					iterX++;
				}
				iterY++;
			}
			if (same == true)
				outputImage[idx] = 255;
		}
	}
}

void erodeCuda(float* inputImage, int inputRow, int inputCol, float* filter, int filterRow, int filterCol, float* outputImage) {
	float* inputCuda, * outputCuda, * filterCuda;

	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&filterCuda, sizeof(float) * filterRow * filterCol);
	cudaMemcpy(filterCuda, filter, sizeof(float) * filterRow * filterCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);
	//cudaMemcpy(outputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);

	dim3 gridDim(inputCol, inputRow, 1);
	erodeKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, filterCuda, filterRow, filterCol, outputCuda);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(filterCuda);
	cudaFree(outputCuda);
}

__global__ void makeNumberGrayKernel(float* inputImage, int inputRow, int inputCol, float number) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int idx = r * inputCol + c;
		inputImage[idx] = number;
	}
}

__global__ void makeNumberRGBKernel(float* inputImage, int inputRow, int inputCol, float number1, float number2, float number3) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int idx = r * inputCol + c;
		inputImage[idx * 3 + 0] = number1;
		inputImage[idx * 3 + 1] = number2;
		inputImage[idx * 3 + 2] = number3;
	}
}

void makeNumberCuda(float* inputImage, int inputRow, int inputCol, int channel, float number1, float number2, float number3) {
	float* inputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);

	dim3 gridDim(inputCol, inputRow, 1);
	if (channel == 1)
		makeNumberGrayKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, number1);
	else if (channel == 3)
		makeNumberRGBKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, number1, number2, number3);

	cudaMemcpy(inputImage, inputCuda, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
}

__global__ void histogramGrayKernel(float* inputImage, int inputRow, int inputCol, float* histogram) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int idx = r * inputCol + c;
		int hIdx = inputImage[idx];
		//histogram[hIdx] += 1;
		atomicAdd((histogram + hIdx), 1);
	}
}

__global__ void histogramRGBKernel(float* inputImage, int inputRow, int inputCol, float* histogram) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int idx = r * inputCol + c;
		int hIdx0 = inputImage[idx * 3 + 0];
		int hIdx1 = inputImage[idx * 3 + 1];
		int hIdx2 = inputImage[idx * 3 + 2];
		//histogram[hIdx0 * 3 + 0] += 1;
		//histogram[hIdx1 * 3 + 1] += 1;
		//histogram[hIdx2 * 3 + 2] += 1;
		atomicAdd((histogram + (hIdx2 * 3 + 0)), 1);
		atomicAdd((histogram + (hIdx2 * 3 + 1)), 1);
		atomicAdd((histogram + (hIdx2 * 3 + 2)), 1);
	}
}

void histogramCuda(float* inputImage, int inputRow, int inputCol, int channel, float* histogram) {
	float* inputCuda, * hisCuda;

	if (channel == 1) {
		for (int i = 0; i < 256; i++)
			histogram[i] = 0;
	}
	else {
		for (int i = 0; i < 256; i++) {
			histogram[i * 3 + 0] = 0;
			histogram[i * 3 + 1] = 0;
			histogram[i * 3 + 2] = 0;
		}
	}
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&hisCuda, sizeof(float) * 256 * channel);
	cudaMemcpy(hisCuda, histogram, sizeof(float) * 256 * channel, cudaMemcpyHostToDevice);

	dim3 gridDim(inputCol, inputRow, 1);
	if (channel == 1)
		histogramGrayKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, hisCuda);
	else if (channel == 3)
		histogramRGBKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, hisCuda);


	cudaMemcpy(histogram, hisCuda, sizeof(float) * 256 * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(hisCuda);
}

__global__ void kmeansGrayClusterChoiceKernel(float* histogram, float* clusters, float* clusterCenters, float* errors, int k) {
	int c = blockIdx.x, r = blockIdx.y;
	if (histogram[r] > 0) {
		int min = (clusterCenters[0] - r) * (clusterCenters[0] - r), temp, minId = 0;
		for (int i = 1; i < k; i++) {
			temp = (clusterCenters[i] - r) * (clusterCenters[i] - r);
			if (temp < min) {
				min = temp;
				minId = i;
			}
		}
		clusters[r] = minId;
		//errors[minId] += min;
		errors[0] += min;
	}
}

__global__ void kmeansGrayCalcClusterCentersKernel(float* histogram, float* clusters, float* clusterCenters, float* clusterMeans, float* clusterElementCount, int k) {
	//int c = blockIdx.x, r = blockIdx.y;
	int c = threadIdx.x, r = threadIdx.y;
	if (histogram[r] > 0) {
		int id = clusters[r];
		atomicAdd((clusterMeans + id), r);
		atomicAdd((clusterElementCount + id), 1);
		//clusterMeans[id] += r;
		//clusterElementCount[id] += 1;
		__syncthreads();
		if (r < k) {
			if (clusterElementCount[r] != 0) {
				clusterMeans[r] /= clusterElementCount[r];
				clusterCenters[r] = clusterMeans[r];
			}
			clusterElementCount[r] = 0;
			clusterMeans[r] = 0;
		}
	}
}

__global__ void kmeansGrayOutputKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* clusters, float* clusterCenters, int k) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int pixel = inputImage[r * inputCol + c];
		int cl = clusters[pixel];
		outputImage[r * inputCol + c] = clusterCenters[cl];
	}
}

__global__ void resetCECKernel(float* clusterElementCount, int k) {
	clusterElementCount[threadIdx.x] = 0;
}

void kmeansGrayCuda(float* inputImage, int inputRow, int inputCol, float* outputImage, int k) {
	//histogram calc
	float* histogram = (float*)malloc(sizeof(float) * 256);

	//cluster centers initialize
	float* clusters = (float*)malloc(sizeof(float) * 256);//256 color = cluster num
	float* clusterCenters = (float*)malloc(sizeof(float) * k);
	float* clusterElementCount = (float*)malloc(sizeof(float) * k);
	float* clusterMeans = (float*)malloc(sizeof(float) * k);
	float* clusterError = (float*)malloc(sizeof(float));//sum of all errors
	float errorOld = -1;
	clusterError[0] = 0;
	int mean = 256 / k;
	for (int i = 0; i < k; i++) {
		clusterCenters[i] = (i)*mean;
		clusterElementCount[i] = 0;
		clusterMeans[i] = 0;
	}
	for (int i = 0; i < 256; i++) {
		mean = rand() % k;
		histogram[i] = 0;
		clusters[i] = mean;
	}
	histogramCuda(inputImage, inputRow, inputCol, 1, histogram);

	float* inputCuda, * histCuda, * outputCuda, * cCuda, * cCCuda, * cECCuda, * cECuda, * cMCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&histCuda, sizeof(float) * 256);
	cudaMemcpy(histCuda, histogram, sizeof(float) * 256, cudaMemcpyHostToDevice);
	cudaMalloc(&cCuda, sizeof(float) * 256);
	cudaMemcpy(cCuda, clusters, sizeof(float) * 256, cudaMemcpyHostToDevice);
	cudaMalloc(&cCCuda, sizeof(float) * k);
	cudaMemcpy(cCCuda, clusterCenters, sizeof(float) * k, cudaMemcpyHostToDevice);
	cudaMalloc(&cECCuda, sizeof(float) * k);
	cudaMemcpy(cECCuda, clusterElementCount, sizeof(float) * k, cudaMemcpyHostToDevice);
	cudaMalloc(&cMCuda, sizeof(float) * k);
	cudaMemcpy(cMCuda, clusterMeans, sizeof(float) * k, cudaMemcpyHostToDevice);
	cudaMalloc(&cECuda, sizeof(float));
	cudaMemcpy(cECuda, clusterError, sizeof(float), cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(inputCol, inputRow, 1);
	dim3 gridDim2(1, 256, 1);
	while (true) {
		kmeansGrayClusterChoiceKernel << <gridDim2, 1 >> > (histCuda, cCuda, cCCuda, cECuda, k);
		//kmeansGrayCalcClusterCentersKernel << <gridDim2, 1 >> > (histCuda, cCuda, cCCuda, cMCuda, cECCuda, k);
		kmeansGrayCalcClusterCentersKernel << <1, gridDim2 >> > (histCuda, cCuda, cCCuda, cMCuda, cECCuda, k);
		cudaMemcpy(clusterError, cECuda, sizeof(float), cudaMemcpyDeviceToHost);
		if (clusterError[0] == errorOld)
			break;
		errorOld = clusterError[0];
		clusterError[0] = 0;
		cudaMemcpy(cECuda, clusterError, sizeof(float), cudaMemcpyHostToDevice);
		//resetCECKernel<<<1,k>>>(cECCuda, k);
	}
	kmeansGrayOutputKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, outputCuda, cCuda, cCCuda, k);

	/*cudaMemcpy(clusterCenters, cCCuda, sizeof(float) * k, cudaMemcpyDeviceToHost);
	cudaMemcpy(clusterElementCount, cECCuda, sizeof(float) * k, cudaMemcpyDeviceToHost);
	for (int i = 0; i < k; i++)
		cout<<clusterCenters[i]<<" "<<clusterElementCount[i] <<endl;*/

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(histCuda);
	cudaFree(outputCuda);
	cudaFree(cCuda);
	cudaFree(cCCuda);
	cudaFree(cECCuda);
	cudaFree(cCCuda);
	cudaFree(cMCuda);
}
__global__ void numberOfColorsKernel(bool* exist, int* number) {
	//if (exist[blockIdx.x] == true) {
	if (exist[threadIdx.x] == true) {
		__syncthreads();
		atomicAdd(number, 1);
		//number[0] += 1;
	}
}

__global__ void compareRGBColorsKernel(float* inputImage, int inputRow, int inputCol, int externalId, bool* exist) {
	int c = blockIdx.x, r = blockIdx.y;
	int id = r * inputCol + c;
	//exist=inputRow*inputCol is all true array for all pixels.if one pixel already exist it is falsed.
	if (id < externalId) {
		if (inputImage[id * 3 + 0] == inputImage[externalId * 3 + 0] && inputImage[id * 3 + 1] == inputImage[externalId * 3 + 1] && inputImage[id * 3 + 2] == inputImage[externalId * 3 + 2])
			exist[externalId] = false;

	}
}

bool* compareRGBColorsCuda(float* inputImage, int inputRow, int inputCol, int* outputHeight) {
	//cout << inputRow * inputCol << endl;//sil
	int externalId;
	bool* exist = (bool*)malloc(sizeof(bool) * inputRow * inputCol);//cuda uzerinde paralel yap
	for (int i = 0; i < inputRow * inputCol; i++)
		exist[i] = true;

	float* inputCuda;
	bool* existCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * 3);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * 3, cudaMemcpyHostToDevice);
	cudaMalloc(&existCuda, sizeof(bool) * inputRow * inputCol);
	cudaMemcpy(existCuda, exist, sizeof(bool) * inputRow * inputCol, cudaMemcpyHostToDevice);

	dim3 gridDim;
	for (int i = 0; i < inputRow; i++) {//baslangici kontrol et
		for (int j = 0; j < inputCol; j++) {
			externalId = i * inputCol + j;
			gridDim = dim3(j + 1, i + 1, 1);
			compareRGBColorsKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, externalId, existCuda);
			//cout << "geldi "<< externalId << endl;//sil
		}
	}

	cudaMemcpy(exist, existCuda, sizeof(bool) * inputRow * inputCol, cudaMemcpyDeviceToHost);

	/*for (int i = 0; i < inputRow; i++) {
		for (int j = 0; j < inputCol; j++) {
			if(exist[i * inputCol + j])
				cout << i <<", "<<j<< "  ";
			//cout << exist[i * inputCol + j] << "  ";
		}
		cout << endl;
	}
	cout << endl;*/

	int* numberCuda, numberOfColors[1] = { 0 };
	cudaMalloc(&numberCuda, sizeof(int));
	cudaMemcpy(numberCuda, numberOfColors, sizeof(int), cudaMemcpyHostToDevice);
	//numberOfColorsKernel << <inputRow * inputCol, 1 >> > (existCuda, numberCuda);
	numberOfColorsKernel << <1, inputRow* inputCol >> > (existCuda, numberCuda);
	cudaMemcpy(numberOfColors, numberCuda, sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(inputCuda);
	cudaFree(existCuda);
	cudaFree(numberCuda);

	outputHeight[0] = numberOfColors[0];
	return exist;
	/*float* colors = (float*)malloc(sizeof(float)* numberOfColors[0] *3);
	int id = 0;
	for (int i = 0; i < inputRow * inputCol; i++)
		if (exist[i] == true) {

			colors[id * 3 + 0] = inputImage[i * 3 + 0];
			colors[id * 3 + 1] = inputImage[i * 3 + 1];
			colors[id * 3 + 2] = inputImage[i * 3 + 2];
			id++;
		}

	return colors;*/
}

bool clusterCentersIsSame(float* newC, float* oldC, int colorsHeight) {
	for (int i = 0; i < colorsHeight; i++) {
		float x = newC[i];
		float y = oldC[i];
		//cout << x << " " << y << endl;//sil
		if (newC[i] != oldC[i])
			return false;
	}
	//cout << endl;//sil
	return true;
}

void copyClusterCenters(float* newC, float* oldC, int colorsHeight) {
	for (int i = 0; i < colorsHeight; i++) {
		oldC[i] = newC[i];
	}
}
__global__ void kmeansRGBOutputKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* clusters, float* clusterCenters, int k, float* colors, int colorHeight) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		int pixel1 = inputImage[(r * inputCol + c) * 3 + 0];
		int pixel2 = inputImage[(r * inputCol + c) * 3 + 1];
		int pixel3 = inputImage[(r * inputCol + c) * 3 + 2];

		//int cl = clusters[pixel];
		int cl = 0;
		for (int i = 0; i < colorHeight; i++) {
			if (pixel1 == colors[i * 3 + 0] && pixel2 == colors[i * 3 + 1] && pixel3 == colors[i * 3 + 2]) {
				cl = i;
				break;
			}
		}

		outputImage[(r * inputCol + c) * 3 + 0] = clusterCenters[cl * 3 + 0];
		outputImage[(r * inputCol + c) * 3 + 1] = clusterCenters[cl * 3 + 1];
		outputImage[(r * inputCol + c) * 3 + 2] = clusterCenters[cl * 3 + 2];
	}
}

__global__ void kmeansRGBClusterChoiceKernel(float* colors, float* clusters, float* clusterCenters, float* errors, int k) {
	int c = blockIdx.x, r = blockIdx.y;
	//int c = threadIdx.x, r = threadIdx.y;
	//int r = threadIdx.x;
	float rr = colors[r * 3 + 0], gg = colors[r * 3 + 1], bb = colors[r * 3 + 2];
	int minId = 0;
	float min =
		(clusterCenters[0] - rr) * (clusterCenters[0] - rr) +
		(clusterCenters[1] - gg) * (clusterCenters[1] - gg) +
		(clusterCenters[2] - bb) * (clusterCenters[2] - bb);
	float temp;
	for (int i = 1; i < k; i++) {
		temp =
			(clusterCenters[i * 3 + 0] - rr) * (clusterCenters[i * 3 + 0] - rr) +
			(clusterCenters[i * 3 + 1] - gg) * (clusterCenters[i * 3 + 1] - gg) +
			(clusterCenters[i * 3 + 2] - bb) * (clusterCenters[i * 3 + 2] - bb);
		if (temp < min) {
			min = temp;
			minId = i;
		}
	}
	clusters[r] = minId;
	/*__syncthreads();
	atomicAdd(errors, min);*/
	//errors[0] += min;
}

__global__ void kmeansRGBCalcClusterCentersKernel(float* colors, float* clusters, float* clusterCenters, float* clusterMeans, float* clusterElementCount, int k) {
	int c = blockIdx.x, r = blockIdx.y;
	//int c = threadIdx.x, r = threadIdx.y;
	//int r = threadIdx.x;
	int id = clusters[r];

	__syncthreads();
	atomicAdd((clusterMeans + (id * 3 + 0)), colors[r * 3 + 0]);
	atomicAdd((clusterMeans + (id * 3 + 1)), colors[r * 3 + 1]);
	atomicAdd((clusterMeans + (id * 3 + 2)), colors[r * 3 + 2]);
	//clusterMeans[id * 3 + 0] += colors[r * 3 + 0];
	//clusterMeans[id * 3 + 1] += colors[r * 3 + 1];
	//clusterMeans[id * 3 + 2] += colors[r * 3 + 2];

	__syncthreads();
	//clusterElementCount[id] += 1;
	atomicAdd(clusterElementCount + id, 1);

	/*__syncthreads();
	if (r < k) {
		clusterMeans[r * 3 + 0] /= clusterElementCount[r * 3 + 0];
		clusterMeans[r * 3 + 1] /= clusterElementCount[r * 3 + 1];
		clusterMeans[r * 3 + 2] /= clusterElementCount[r * 3 + 2];
		clusterCenters[r * 3 + 0] = clusterMeans[r * 3 + 0];
		clusterCenters[r * 3 + 1] = clusterMeans[r * 3 + 1];
		clusterCenters[r * 3 + 2] = clusterMeans[r * 3 + 2];
		clusterElementCount[r] = 0;
		clusterMeans[r * 3 + 0] = 0;
		clusterMeans[r * 3 + 1] = 0;
		clusterMeans[r * 3 + 2] = 0;
	}*/
}

__global__ void refreshVariables(float* clusterCenters, float* clusterMeans, float* clusterElementCount) {
	int r = threadIdx.x;
	if (clusterElementCount[r] != 0) {
		clusterMeans[r * 3 + 0] /= clusterElementCount[r];
		clusterMeans[r * 3 + 1] /= clusterElementCount[r];
		clusterMeans[r * 3 + 2] /= clusterElementCount[r];
		clusterCenters[r * 3 + 0] = clusterMeans[r * 3 + 0];
		clusterCenters[r * 3 + 1] = clusterMeans[r * 3 + 1];
		clusterCenters[r * 3 + 2] = clusterMeans[r * 3 + 2];
	}
	clusterElementCount[r] = 0;
	clusterMeans[r * 3 + 0] = 0;
	clusterMeans[r * 3 + 1] = 0;
	clusterMeans[r * 3 + 2] = 0;
}

void kmeansRGBCuda(float* inputImage, int inputRow, int inputCol, float* outputImage, int k, float* colors, int colorsHeight) {
	int channel = 3;
	/*for(int i=0;i<5;i++)//sil
		cout << colors[i*3+0]<<" " << colors[i*3+1] << " " << colors[i*3+2] << " " << endl;
	cout << colorsHeight << endl;*/

	float* clusters = (float*)malloc(sizeof(float) * colorsHeight);//holds sets of colors
	float* clusterCenters = (float*)malloc(sizeof(float) * k * channel);
	float* clusterElementCount = (float*)malloc(sizeof(float) * k);
	float* clusterMeans = (float*)malloc(sizeof(float) * k * channel);
	float* clusterError = (float*)malloc(sizeof(float));//sum of all errors
	float errorOld = -1;
	float* clustersOld = (float*)malloc(sizeof(float) * colorsHeight);
	clusterError[0] = 0;
	int mean = 256 / k;
	for (int i = 0; i < k; i++) {
		clusterCenters[i * 3 + 0] = (i)*mean;//rand() % 255;//colors[i * 3 + 0];//
		clusterCenters[i * 3 + 1] = (i)*mean;//rand() % 255;//colors[i * 3 + 1];//
		clusterCenters[i * 3 + 2] = (i)*mean;//rand() % 255;//colors[i * 3 + 2];//
		clusterElementCount[i] = 0;
		clusterMeans[i * 3 + 0] = 0;
		clusterMeans[i * 3 + 1] = 0;
		clusterMeans[i * 3 + 2] = 0;
	}
	for (int i = 0; i < colorsHeight; i++) {
		mean = rand() % k;
		clusters[i] = mean;
		clustersOld[i] = mean;
	}

	/*for (int i = 0; i < k; i++)//sil
		cout << clusterCenters[i * 3 + 0] << " " << clusterCenters[i * 3 + 1] << " " << clusterCenters[i * 3 + 2] << " " << clusterElementCount[i] << endl;
	cout << endl;
	for (int i = 0; i < colorsHeight; i++)//sil
		//cout << clusters[i]<<endl;
		cout << colors[i * 3 + 0] << " " << colors[i * 3 + 1] << " " << colors[i * 3 + 2] << endl;
	cout << endl;*/

	float* inputCuda, * colorsCuda, * outputCuda, * cCuda, * cCCuda, * cECCuda, * cECuda, * cMCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&colorsCuda, sizeof(float) * colorsHeight * channel);
	cudaMemcpy(colorsCuda, colors, sizeof(float) * colorsHeight * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&cCuda, sizeof(float) * colorsHeight);
	cudaMemcpy(cCuda, clusters, sizeof(float) * colorsHeight, cudaMemcpyHostToDevice);
	cudaMalloc(&cCCuda, sizeof(float) * k * channel);
	cudaMemcpy(cCCuda, clusterCenters, sizeof(float) * k * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&cECCuda, sizeof(float) * k);
	cudaMemcpy(cECCuda, clusterElementCount, sizeof(float) * k, cudaMemcpyHostToDevice);
	cudaMalloc(&cMCuda, sizeof(float) * k * channel);
	cudaMemcpy(cMCuda, clusterMeans, sizeof(float) * k * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&cECuda, sizeof(float));
	cudaMemcpy(cECuda, clusterError, sizeof(float), cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol * channel);

	dim3 gridDim(inputCol, inputRow, 1);
	dim3 gridDim2(1, colorsHeight, 1);
	while (true) {
		kmeansRGBClusterChoiceKernel << <gridDim2, 1 >> > (colorsCuda, cCuda, cCCuda, cECuda, k);
		//kmeansRGBClusterChoiceKernel << <1, gridDim2 >> > (colorsCuda, cCuda, cCCuda, cECuda, k);							
		//kmeansRGBClusterChoiceKernel << <1, colorsHeight >> > (colorsCuda, cCuda, cCCuda, cECuda, k);

		kmeansRGBCalcClusterCentersKernel << <gridDim2, 1 >> > (colorsCuda, cCuda, cCCuda, cMCuda, cECCuda, k);
		//kmeansRGBCalcClusterCentersKernel << <1, gridDim2 >> > (colorsCuda, cCuda, cCCuda, cMCuda, cECCuda, k);	
		//kmeansRGBCalcClusterCentersKernel << <1, colorsHeight >> > (colorsCuda, cCuda, cCCuda, cMCuda, cECCuda, k);

		cudaMemcpy(clusters, cCuda, sizeof(float) * colorsHeight, cudaMemcpyDeviceToHost);

		/*cout << endl;//sil
		for (int i = 0; i < colorsHeight; i++)
			cout << clusters[i] << endl;
		cout << endl;*/

		if (clusterCentersIsSame(clusters, clustersOld, colorsHeight) == true)
			break;
		copyClusterCenters(clusters, clustersOld, colorsHeight);

		refreshVariables << <1, k >> > (cCCuda, cMCuda, cECCuda);
	}
	kmeansRGBOutputKernel << <gridDim, 1 >> > (inputCuda, inputRow, inputCol, outputCuda, cCuda, cCCuda, k, colorsCuda, colorsHeight);


	/*cudaMemcpy(clusters, cCuda, sizeof(float) * colorsHeight, cudaMemcpyDeviceToHost);//sil
	for (int i = 0; i < colorsHeight; i++)
		cout << clusters[i] << endl;

	cudaMemcpy(clusterCenters, cCCuda, sizeof(float) * k * channel, cudaMemcpyDeviceToHost);//sil
	cudaMemcpy(clusterElementCount, cECCuda, sizeof(float) * k, cudaMemcpyDeviceToHost);
	for (int i = 0; i < k; i++)
		cout << clusterCenters[i*3+0] << " " << clusterCenters[i * 3 + 1] << " " << clusterCenters[i * 3 + 2] << " " << clusterElementCount[i] << endl;
	*/

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyDeviceToHost);
	cudaFree(colorsCuda);
	cudaFree(outputCuda);
	cudaFree(cCuda);
	cudaFree(cCCuda);
	cudaFree(cECCuda);
	cudaFree(cCCuda);
	cudaFree(cMCuda);
}

__global__ void addImagesGrayKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		outputImage[r * inputCol + c] = inputImage[r * inputCol + c] * alpha + inputImage2[r * inputCol + c] * beta;
	}
}

__global__ void addImagesRGBKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		outputImage[(r * inputCol + c) * 3 + 0] = inputImage[(r * inputCol + c) * 3 + 0] * alpha + inputImage2[(r * inputCol + c) * 3 + 0] * beta;
		outputImage[(r * inputCol + c) * 3 + 1] = inputImage[(r * inputCol + c) * 3 + 1] * alpha + inputImage2[(r * inputCol + c) * 3 + 1] * beta;
		outputImage[(r * inputCol + c) * 3 + 2] = inputImage[(r * inputCol + c) * 3 + 2] * alpha + inputImage2[(r * inputCol + c) * 3 + 2] * beta;
	}
}

void addImagesCuda(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, float alpha, float beta, int channel) {
	float* inputCuda, * inputCuda2, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&inputCuda2, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda2, inputImage2, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol * channel);

	dim3 gridDim(inputCol, inputRow, 1);
	if (channel == 1) {
		addImagesGrayKernel << <gridDim, 1 >> > (inputCuda, inputCuda2, outputCuda, inputRow, inputCol, alpha, beta);
	}
	else if (channel == 3) {
		addImagesRGBKernel << <gridDim, 1 >> > (inputCuda, inputCuda2, outputCuda, inputRow, inputCol, alpha, beta);
	}

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(inputCuda2);
	cudaFree(outputCuda);
}

__global__ void subtractImagesGrayKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		outputImage[r * inputCol + c] = inputImage[r * inputCol + c] - inputImage2[r * inputCol + c];
	}
}

__global__ void subtractImagesRGBKernel(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		outputImage[(r * inputCol + c) * 3 + 0] = inputImage[(r * inputCol + c) * 3 + 0] - inputImage2[(r * inputCol + c) * 3 + 0];
		outputImage[(r * inputCol + c) * 3 + 1] = inputImage[(r * inputCol + c) * 3 + 1] - inputImage2[(r * inputCol + c) * 3 + 1];
		outputImage[(r * inputCol + c) * 3 + 2] = inputImage[(r * inputCol + c) * 3 + 2] - inputImage2[(r * inputCol + c) * 3 + 2];
	}
}

void subtractImagesCuda(float* inputImage, float* inputImage2, float* outputImage, int inputRow, int inputCol, int channel) {
	float* inputCuda, * inputCuda2, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&inputCuda2, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda2, inputImage2, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol * channel);

	dim3 gridDim(inputCol, inputRow, 1);
	if (channel == 1) {
		subtractImagesGrayKernel << <gridDim, 1 >> > (inputCuda, inputCuda2, outputCuda, inputRow, inputCol);
	}
	else if (channel == 3) {
		subtractImagesRGBKernel << <gridDim, 1 >> > (inputCuda, inputCuda2, outputCuda, inputRow, inputCol);
	}

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(inputCuda2);
	cudaFree(outputCuda);
}

__global__ void clipGrayImagesKernel(float* inputImage, float* outputImage, int inputRow, int inputCol, int low, int high) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		if (inputImage[r * inputCol + c] > high)
			outputImage[r * inputCol + c] = high;
		else if ((inputImage[r * inputCol + c] < low))
			outputImage[r * inputCol + c] = low;
		else
			outputImage[r * inputCol + c] = inputImage[r * inputCol + c];
	}
}

__global__ void clipRGBImagesKernel(float* inputImage, float* outputImage, int inputRow, int inputCol, int low, int high) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < inputCol && r < inputRow) {
		float rr = inputImage[(r * inputCol + c) * 3 + 0], gg = inputImage[(r * inputCol + c) * 3 + 1], bb = inputImage[(r * inputCol + c) * 3 + 2];

		if (inputImage[(r * inputCol + c) * 3 + 0] > high)
			rr = high;
		else if ((inputImage[(r * inputCol + c) * 3 + 0] < low))
			rr = low;
		if (inputImage[(r * inputCol + c) * 3 + 1] > high)
			gg = high;
		else if ((inputImage[(r * inputCol + c) * 3 + 1] < low))
			gg = low;
		if (inputImage[(r * inputCol + c) * 3 + 2] > high)
			bb = high;
		else if ((inputImage[(r * inputCol + c) * 3 + 2] < low))
			bb = low;

		outputImage[(r * inputCol + c) * 3 + 0] = rr;
		outputImage[(r * inputCol + c) * 3 + 1] = gg;
		outputImage[(r * inputCol + c) * 3 + 2] = bb;
	}
}

void clipImagesCuda(float* inputImage, float* outputImage, int inputRow, int inputCol, int channel, int low, int high) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol * channel);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol * channel);

	dim3 gridDim(inputCol, inputRow, 1);
	if (channel == 1) {
		clipGrayImagesKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputRow, inputCol, low, high);
	}
	else if (channel == 3) {
		clipRGBImagesKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputRow, inputCol, low, high);
	}

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol * channel, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}

__global__ void otsuKernel(float* histogram, int inputRow, int inputCol, float* weightXVariance) {//weightXVariance 254x2
	//2x254
	int c = blockIdx.x, r = blockIdx.y;
	//r cant be 0 or 255

	float weight = 0, mean = 0, variance = 0, colorNum = 0;
	if (c == 0) {
		for (int i = 0; i < r + 1; i++) {
			weight += histogram[i];
			mean += i * histogram[i];
			colorNum += histogram[i];
		}
		if (colorNum == 0)
			colorNum = 1;
		weight = weight / (inputRow * inputCol);
		mean = mean / colorNum;

		for (int i = 0; i < r + 1; i++) {
			variance += (i - mean) * (i - mean) * histogram[i];
		}

	}
	else if (c == 1) {
		for (int i = r + 1; i < 256; i++) {
			weight += histogram[i];
			mean += i * histogram[i];
			colorNum += histogram[i];
		}
		if (colorNum == 0)
			colorNum = 1;
		weight = weight / (inputRow * inputCol);
		mean = mean / colorNum;

		for (int i = r + 1; i < 256; i++) {
			variance += (i - mean) * (i - mean) * histogram[i];
		}
	}
	variance = variance / colorNum;
	weightXVariance[r * 2 + c] = variance * weight;
}

float otsuCuda(float* inputImage, int inputRow, int inputCol) {
	float* histogram = (float*)malloc(sizeof(float) * 256);
	histogramCuda(inputImage, inputRow, inputCol, 1, histogram);
	float* weightXVariance = (float*)malloc(sizeof(float) * 254 * 2);
	float* histCuda, * wXVCuda;

	cudaMalloc(&histCuda, sizeof(float) * 256);
	cudaMemcpy(histCuda, histogram, sizeof(float) * 256, cudaMemcpyHostToDevice);
	cudaMalloc(&wXVCuda, sizeof(float) * 254 * 2);

	dim3 gridDim(2, 254, 1);
	otsuKernel << <gridDim, 1 >> > (histCuda, inputRow, inputCol, wXVCuda);
	cudaMemcpy(weightXVariance, wXVCuda, sizeof(float) * 254 * 2, cudaMemcpyDeviceToHost);

	float min = weightXVariance[0 * 2 + 0] + weightXVariance[0 * 2 + 1], minId = 1, temp;
	for (int i = 1; i < 254; i++) {
		temp = weightXVariance[i * 2 + 0] + weightXVariance[i * 2 + 1];
		if (temp < min) {
			min = temp;
			minId = i + 1;
		}
	}

	cudaFree(histCuda);
	cudaFree(wXVCuda);

	return minId;
}

__global__ void histEqualKernel(float* histogram, int inputRow, int inputCol, float* newColors) {
	int c = blockIdx.x, r = blockIdx.y;
	if (c < 1 && r < 256 && blockIdx.z == 0) {
		float sum = 0;
		for (int i = r; i >= 0; i--) {
			sum += histogram[i];
		}
		sum = sum / (inputRow * inputCol);
		float maxColor = 256.0;
		sum *= (maxColor - 1.0);
		newColors[r] = round(sum);
	}
}

__global__ void histEqualPaintKernel(float* inputImage, int inputRow, int inputCol, float* outputImage, float* newColors) {
	int c = blockIdx.x, r = blockIdx.y;
	int id = inputImage[r * inputCol + c];
	outputImage[r * inputCol + c] = newColors[id];
}

void histEqualCuda(float* inputImage, int inputRow, int inputCol, float* outputImage) {
	float maxColor = 256;
	float* histogram = (float*)malloc(sizeof(float) * maxColor);
	histogramCuda(inputImage, inputRow, inputCol, 1, histogram);
	float* histCuda, * newColorsCuda, * inputCuda, * outputCuda;
	cudaMalloc(&histCuda, sizeof(float) * maxColor);
	cudaMemcpy(histCuda, histogram, sizeof(float) * maxColor, cudaMemcpyHostToDevice);
	cudaMalloc(&newColorsCuda, sizeof(float) * maxColor);
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(1, maxColor, 1);
	dim3 gridDim2(inputCol, inputRow, 1);

	histEqualKernel << <gridDim, 1 >> > (histCuda, inputRow, inputCol, newColorsCuda);
	histEqualPaintKernel << <gridDim2, 1 >> > (inputCuda, inputRow, inputCol, outputCuda, newColorsCuda);

	/*float *newColors= (float*)malloc(sizeof(float) * maxColor);
	cudaMemcpy(newColors, newColorsCuda, sizeof(float) * maxColor, cudaMemcpyDeviceToHost);
	int s = 0;
	for (int i = 0; i < maxColor; i++) {
		cout << i << "  " << histogram[i] << "  " << newColors[i] << endl;
		s += histogram[i];
	}
	cout << inputRow * inputCol<<" "<<s;*/

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
	cudaFree(histCuda);
	cudaFree(newColorsCuda);
}

__global__ void reverseImageKernel(float* inputImage, float* outputImage, int inputRow, int inputCol) {
	int c = blockIdx.x, r = blockIdx.y;
	outputImage[r * inputCol + c] = 255 - inputImage[r * inputCol + c];
}

void reverseImageCuda(float* inputImage, float* outputImage, int inputRow, int inputCol) {
	float* inputCuda, * outputCuda;
	cudaMalloc(&inputCuda, sizeof(float) * inputRow * inputCol);
	cudaMemcpy(inputCuda, inputImage, sizeof(float) * inputRow * inputCol, cudaMemcpyHostToDevice);
	cudaMalloc(&outputCuda, sizeof(float) * inputRow * inputCol);

	dim3 gridDim(inputCol, inputRow, 1);
	reverseImageKernel << <gridDim, 1 >> > (inputCuda, outputCuda, inputRow, inputCol);

	cudaMemcpy(outputImage, outputCuda, sizeof(float) * inputRow * inputCol, cudaMemcpyDeviceToHost);
	cudaFree(inputCuda);
	cudaFree(outputCuda);
}