#include <stdio.h>
#include <time.h>

typedef struct {
	long width;
	long height;
	float *element;
} Matrix;

__global__ void sum(long N, const Matrix A, const Matrix B, Matrix C) {
	int i = threadIdx.x;

	if (i<N) {
		C.element[i] = A.element[i]+B.element[i];
	}
}

int main(void) {
	long DIM_0 = 1<<10;
	long DIM_1 = 1<<10;
	//	CUDA Performance Variables
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	//	Declare initial parameters
	long N = DIM_0*DIM_1;
	size_t size = N*sizeof(float);
	//	Create Host variables
	Matrix mA = {DIM_0, DIM_1};
	Matrix mB = {DIM_0, DIM_1};
	Matrix mC = {DIM_0, DIM_1};
	//	Create Device variables
	Matrix d_mA = {DIM_0, DIM_1};
	Matrix d_mB = {DIM_0, DIM_1};
	Matrix d_mC = {DIM_0, DIM_1};
	//	Allocate memory for Host
	mA.element = (float*)malloc(size);
	mB.element = (float*)malloc(size);
	mC.element = (float*)malloc(size);
	//	Set Host values
	for (long i=0; i<(DIM_0*DIM_1); i++) {
		mA.element[i] = 1;
		mB.element[i] = 1;
	}
	//	Allocate memory for Device
	cudaMalloc(&d_mA.element, size);
	cudaMalloc(&d_mB.element, size);
	cudaMalloc(&d_mC.element, size);
	//	Set Device values
	cudaMemcpy(d_mA.element, mA.element, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_mB.element, mB.element, size, cudaMemcpyHostToDevice);
	//	Send kernel to Device
	dim3 threadsPerBlock(256);
	dim3 blocksPerGrid((N-1+256)/255);
	cudaEventRecord(start);
	sum<<<blocksPerGrid, threadsPerBlock>>>(N, d_mA, d_mB, d_mC);
	//sum<<<1, 4>>>(N, d_mA, d_mB, d_mC);
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float milliseconds = 0;
	float microseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);
	microseconds = milliseconds*1000;
	//	Retrieve Device variables
	cudaMemcpy(mC.element, d_mC.element, size, cudaMemcpyDeviceToHost);
	//	Print results
	printf("%f    %f\n", mC.element[0], mC.element[1]);
	printf("%f    %f\n", mC.element[2], mC.element[3]);
	printf("Time taken (microseconds): %f\n", microseconds);
	free(mA.element);
	free(mB.element);
	free(mC.element);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	return 0;
}

