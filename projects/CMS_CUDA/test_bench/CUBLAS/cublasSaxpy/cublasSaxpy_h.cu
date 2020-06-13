#include <stdio.h>
#include "cublas.h"
#include "cublas_v2.h"
#include "cuda_runtime.h"

int main() {
	int arraySize = 333;

	float *x, *y;
	float *d_x, *d_y;

	x = (float*)malloc(sizeof(float)*arraySize);
	y = (float*)malloc(sizeof(float)*arraySize);

	cudaMalloc((void**) &d_x, sizeof(float)*arraySize);
	cudaMalloc((void**) &d_y, sizeof(float)*arraySize);

	for (int i=0; i<arraySize; i++) x[i] = 0.8f;
	for (int i=0; i<arraySize; i++) y[i] = 0.6f;
	
	cudaMemcpy(d_x, x, sizeof(float)*arraySize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, sizeof(float)*arraySize, cudaMemcpyHostToDevice);

	float *y_old;
	y_old = (float*)malloc(sizeof(float)*arraySize);
	for (int i=0; i<arraySize; i++) y_old[i] = y[i];

	float alpha = 0.4f;

	cublasStatus_t status;
	cublasHandle_t handle;
	status = cublasCreate(&handle);
	float milli0 = 0;
	cudaEvent_t start0, stop0;
	cudaEventCreate(&start0);
	cudaEventCreate(&stop0);

	cudaEventRecord(start0, 0);
	status = cublasSetVector(arraySize,sizeof(float),x,1,d_x,1);
	status = cublasSetVector(arraySize,sizeof(float),y,1,d_y,1);
	//---------------------------------------------------------------------
	status = cublasSaxpy(handle, arraySize, &alpha, d_x, 1, d_y, 1);
	//---------------------------------------------------------------------
	status = cublasGetVector(arraySize,sizeof(float),d_y,1,y,1);
	cudaEventRecord(stop0, 0);
	cudaEventSynchronize(stop0);
	cudaEventElapsedTime(&milli0, start0, stop0);

	cudaEventDestroy(start0);
	cudaEventDestroy(stop0);
	float micro0 = milli0*1000;
	cublasDestroy(handle);
	
	printf("%f,%f\n", y_old[0], y[0]);
	
	printf("cublasSaxpy: Kernel = %f us\n", micro0);

	if (status) {};

	cudaFree(d_x);
	cudaFree(d_y);

	free(x);
	free(y);
	free(y_old);

	return 0;
}
