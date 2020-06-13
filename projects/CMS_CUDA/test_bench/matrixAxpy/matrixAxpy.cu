#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//__global__ void Mat_add(double A[], double B[], double C[], double alpha[], int m, int n) {
__global__ void Mat_add(double *A, double *B, double *C, double *alpha, int m, int n) {
	int my_ij = blockDim.x * blockIdx.x + threadIdx.x;
	if (blockIdx.x < m && threadIdx.x < n) 
		C[my_ij] = A[my_ij] - alpha[0]*B[my_ij];
} 

/* Host code */
int main(int argc, char* argv[]) {
	int m, n;
	double *h_A, *h_B, *h_C, *h_alpha;
	double *d_A, *d_B, *d_C, *d_alpha;
	size_t size;

	/* Get size of matrices */
	if (argc != 3) {
		fprintf(stderr, "usage: %s <row count> <col count>\n", argv[0]);
		exit(0);
	}
	m = strtol(argv[1], NULL, 10);
	n = strtol(argv[2], NULL, 10);
	printf("m = %d, n = %d\n", m, n);
	size = m*n*sizeof(double);

	h_A     = (double*)malloc(size);
	h_B     = (double*)malloc(size);
	h_C     = (double*)malloc(size);
	h_alpha = (double*)malloc(size);

	for (int i = 0; i < m; i++)
		for (int j = 0; j < n; j++) {
			h_A[i*n+j] = 2.0f;
			h_B[i*n+j] = 4.0f;
			h_C[i*n+j] = 0.0f;
			h_alpha[i*n+j] = 6.0f;
		}

	/* Allocate matrices in device memory */
	cudaMalloc(&d_A    , size);
	cudaMalloc(&d_B    , size);
	cudaMalloc(&d_C    , size);
	cudaMalloc(&d_alpha, size);

	/* Copy matrices from host memory to device memory */
	cudaMemcpy(d_A    , h_A    , size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B    , h_B    , size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_alpha, h_alpha, size, cudaMemcpyHostToDevice);

	/* Invoke kernel using m thread blocks, each of    */
	/* which contains n threads                        */
	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
	Mat_add<<<m, n>>>(d_A, d_B, d_C, d_alpha, m, n);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);

	/* Wait for the kernel to complete */
	cudaThreadSynchronize();

	/* Copy result from device memory to host memory */
	cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

//	for (int i = 0; i < m; i++)
//		for (int j = 0; j < n; j++) 
//			printf("%f   %f   %f\n", h_A[i*n+j], h_B[i*n+j], h_C[i*n+j]);
	printf("%f ms\n", milli);
	/* Free device memory */
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	cudaFree(d_alpha);

	/* Free host memory */
	free(h_A);
	free(h_B);
	free(h_C);
	free(h_alpha);

	return 0;
}  /* main */
