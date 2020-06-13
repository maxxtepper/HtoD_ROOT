#include <stdio.h>
#include "cublas_v2.h"

int main() {
	int arraySize = 1000000;
	float *a = (float*)malloc(sizeof(float)*arraySize);
	float *d_a;
	cudaMalloc((void**) &d_a, sizeof(float)*arraySize);
	for (int i=0; i<arraySize; i++) a[i] = 0.8f;
	cudaMemcpy(d_a, a, sizeof(float)*arraySize, cudaMemcpyHostToDevice);

	cublasHandle_t handle;
	cublasCreate(&handle);

	float *cb_result = (float*)malloc(sizeof(float));

	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);

	cublasSasum(handle, arraySize, d_a, 1, cb_result);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;

	printf("\nCUBLAS: %.3f\n\n", *cb_result);
	printf("time = %f us\n",micro);

	cublasDestroy(handle);

	return 0;
}
