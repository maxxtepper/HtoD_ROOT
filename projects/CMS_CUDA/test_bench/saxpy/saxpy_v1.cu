#include <stdio.h>

__global__
void saxpy(int n, float a, float *x, float *y) {
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	if (i < n) y[i] = a*x[i] + y[i];
}

int main(void) {
	//int N = 1<<20;
	//int N = 1<<8;
	int N = 333;
	//  Host Variables (CPU)
	float *x, *y;
	//  Device Variables (GPU)
	float *d_x, *d_y;
	//  Allocate memory in Host
	x = (float*)malloc(N*sizeof(float));
	y = (float*)malloc(N*sizeof(float));
	//  Allocate memory in Device
	cudaMalloc(&d_x, N*sizeof(float));
	cudaMalloc(&d_y, N*sizeof(float));
	//  Set Host variable values
	for (int i=0; i<N; i++) {
		x[i] = 1.0f;
		y[i] = 2.0f;
	}
	//  Send Host variables to Device variables
	cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);
	//  Send kernel to Device 

	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);

	saxpy<<<(N+255)/256, 256>>>(N, 2.0f, d_x, d_y);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;

	//  Retrieve Device variables
	cudaMemcpy(y, d_y, N*sizeof(float), cudaMemcpyDeviceToHost);
	//  Calculate error
	float maxError = 0.0f;
	for (int i=0; i<N; i++) {
		maxError = max(maxError, abs(y[i]-4.0f));
	}
	printf("Max error: %f\n", maxError);
	printf("time = %f us\n",micro);
}
