#include <stdio.h>
#include <stdlib.h>

__global__
void saxpy(int n, double a[], double x[], double y[]) {
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	if (i < n) y[i] = a[i]*x[i] + y[i];
}

int main(void) {
	//int N = 1<<20;
	//int N = 1<<8;
	int N = 333;
	//  Host Variables (CPU)
	double *x, *y, *a;
	//  Device Variables (GPU)
	double *d_x, *d_y, *d_a;
	//  Allocate memory in Host
	x = (double*)malloc(N*sizeof(double));
	y = (double*)malloc(N*sizeof(double));
	a = (double*)malloc(N*sizeof(double));
	//  Allocate memory in Device
	cudaMalloc(&d_x, N*sizeof(double));
	cudaMalloc(&d_y, N*sizeof(double));
	cudaMalloc(&d_a, N*sizeof(double));
	//  Set Host variable values
	for (int i=0; i<N; i++) {
		x[i] = rand() % 1<<20;
		y[i] = rand() % 1<<20;
		a[i] = 2.0f;
	}
	//  Send Host variables to Device variables
	cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(d_a, a, N*sizeof(double), cudaMemcpyHostToDevice);
	//  Send kernel to Device 

	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);

//	saxpy<<<(N+255)/256, 256>>>(N, d_a, d_x, d_y);
	saxpy<<<1,333>>>(N, d_a, d_x, d_y);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;

	//  Retrieve Device variables
	cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);
	//  Calculate error
	double maxError = 0.0f;
	for (int i=0; i<N; i++) {
		maxError = max(maxError, abs(y[i]-4.0f));
	}
	printf("Max error: %f\n", maxError);
	printf("time = %f us\n",micro);


	cudaFree(d_x);
	cudaFree(d_y);
	cudaFree(d_a);
	free(x);
	free(y);
	free(a);
}
