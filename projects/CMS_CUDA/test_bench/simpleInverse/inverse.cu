#include <stdio.h>

__global__
void inverse(int n, double *x, double *y, double *z) {
	int i = threadIdx.x;
	if (i < n) z[0] = 1/(x[0]+y[0]);
}

int main(void) {
	int N = 333;
	int bytes = N*sizeof(double);

	double *x, *y, *z;
	double *d_x, *d_y, *d_z;

	x = (double*)malloc(bytes);
	y = (double*)malloc(bytes);
	z = (double*)malloc(bytes);

	cudaMalloc(&d_x, bytes);
	cudaMalloc(&d_y, bytes);
	cudaMalloc(&d_z, bytes);

	x[0] = 1.0f;
	y[0] = 2.0f;

	cudaMemcpy(d_x, x, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, bytes, cudaMemcpyHostToDevice);

	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);

	inverse<<<1,1>>>(N, d_x, d_y, d_z);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;

	cudaMemcpy(z, d_z, bytes, cudaMemcpyDeviceToHost);

	double answer = 1/(x[0]+y[0]);

	printf("answer = %f\n", answer);
	printf("z      = %f\n", z[0]);
	printf("time   = %f us\n",micro);

	free(x);
	free(y);
	free(z);

	cudaFree(d_x);
	cudaFree(d_y);
	cudaFree(d_z);

	return 0;
}
