#include <stdio.h>
#include "cublas_v2.h"
#include "cuda_runtime.h"

//__constant__ float alpha;
//__device__ __global__ float alpha;

int main() {
	int arraySize = 333;

	float *x, *y, *a;
	float *d_x, *d_y, *d_a;

	x = (float*)malloc(sizeof(float)*arraySize);
	y = (float*)malloc(sizeof(float)*arraySize);
	a = (float*)malloc(sizeof(float)*arraySize);

	cudaMalloc((void**) &d_x, sizeof(float)*arraySize);
	cudaMalloc((void**) &d_y, sizeof(float)*arraySize);
	cudaMalloc((void**) &d_a, sizeof(float)*arraySize);

	for (int i=0; i<arraySize; i++) x[i] = 0.8f;
	for (int i=0; i<arraySize; i++) y[i] = 0.6f;
	for (int i=0; i<arraySize; i++) a[i] = 0.4f;
//	a[0] = 0.4f;

	cudaMemcpy(d_x, x, sizeof(float)*arraySize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, sizeof(float)*arraySize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_a, a, sizeof(float)*arraySize, cudaMemcpyHostToDevice);
//	cudaMemcpyToSymbol(alpha, a, sizeof(float), 0, cudaMemcpyHostToDevice);
//	cudaGetSymbolAddress((float**)d_alpha, alpha);

	float *y_old;
	y_old = (float*)malloc(sizeof(float)*arraySize);
	for (int i=0; i<arraySize; i++) y_old[i] = y[i];

	cublasStatus_t status;
	cublasHandle_t handle;
	status = cublasCreate(&handle);
	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	status = cublasSetVector(arraySize,sizeof(float),x,1,d_x,1);
	status = cublasSetVector(arraySize,sizeof(float),y,1,d_y,1);
	//-----------------------------------------------------------------
	status = cublasSaxpy(handle, arraySize, d_a, d_x, 1, d_y, 1);
	//-----------------------------------------------------------------
	status = cublasGetVector(arraySize,sizeof(float),d_y,1,y,1);

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;
	cublasDestroy(handle);
	
	for (int i=0; i<arraySize; i++) {
		printf("%f,%f\n", y_old[i], y[i]);
	}
	
	printf("cublasSaxpy time = %f us\n", micro);

	if (status){};

	cudaFree(d_x);
	cudaFree(d_y);
	cudaFree(d_a);

	free(x);
	free(y);
	free(a);
	free(y_old);

	return 0;
}
