#include <stdio.h>
#include "nanoTime.h"

#define M 8

__global__ void product_sumAB(int N, float *a, float *b, float *c, float *d);

int main (void) {
    //  Initialize parameters
		printf("2x2matrixMult_v2\n");
    int DIM_0 = 2;
    int DIM_1 = 2;
    int N = DIM_0*DIM_1;
    size_t size = N*sizeof(float);
    //  Declare Host variables
    float *a, *b, *c, *d;
    //  Declare Device variables
    float *d_a, *d_b, *d_c, *d_d;
    //  Allocate Host variables
    a = (float*)malloc(size*2);
    b = (float*)malloc(size*2);
    c = (float*)malloc(size*2);
    d = (float*)malloc(size);
    //  Allocate Device variables
    cudaMalloc(&d_a, size*2);
    cudaMalloc(&d_b, size*2);
    cudaMalloc(&d_c, size*2);
    cudaMalloc(&d_d, size);
    //  Set Host variables
    a[0] = 1;
    a[1] = 1;
    a[2] = 3;
    a[3] = 3;
    a[4] = 2;
    a[5] = 2;
    a[6] = 4;
    a[7] = 4;
    b[0] = 5;
    b[1] = 6;
    b[2] = 5;
    b[3] = 6;
    b[4] = 7;
    b[5] = 8;
    b[6] = 7;
    b[7] = 8;
    //  Initialize Device Event Handeling
		float milli = 0;
		float micro = 0;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    //  Set Device variables
		cudaEventRecord(start);
		cudaMemcpy(d_a, a, size*2, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size*2, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_d, d, size, cudaMemcpyHostToDevice);
		cudaEventRecord(stop);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&milli, start, stop);
		micro += (milli*1000);
    //  Initialize Host Event Handeling
    struct timespec vartime;
    float time_elapsed_nanos;
    /////////////////////////////////////////////////////////
    ////  GPU Calculation  //////////////////////////////////
//		for (int i=0; i<100000; i++) {
			//  Kernel 0 (Products and Sums)
//			cudaEventRecord(start);
			product_sumAB<<<1,8>>>(N, d_a, d_b, d_c, d_d);
//			cudaEventRecord(stop);
//			cudaEventSynchronize(stop);
			//  Device Event Results
//		}
//		micro /= 100000;
    //  Kernels Complete
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //  Get Device variables
    cudaMemcpy(d, d_d, size, cudaMemcpyDeviceToHost);
    //  Results (GPU)
    printf("GPU Calculation:\n");
    //printf("%f     %f\n", d[0], d[1]);
    //printf("%f     %f\n", d[2], d[3]);
    printf("Elapsed Time (microseconds): %f\n", micro);
    /////////////////////////////////////////////////////////
    ////  CPU Calculation  //////////////////////////////////
    vartime = timer_start();
    for (int i=0; i<8; i++) c[i] = a[i]*b[i];
    for (int i=0; i<4; i++) d[i] = c[i]+c[i+4];
    time_elapsed_nanos = timer_end(vartime);
		float time_elapsed_micro = time_elapsed_nanos/1000;
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //  Results (CPU)
    printf("CPU Calculation:\n");
    //printf("%f     %f\n", d[0], d[1]);
    //printf("%f     %f\n", d[2], d[3]);
    printf("Elapsed Time (microseconds): %f\n", time_elapsed_micro);
    //  Deallocate Host variables
    free(a);
    free(b);
    free(c);
    free(d);
    //  Deallocate Device variables
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaFree(d_d);
    return 0;
}

__global__ void product_sumAB(int N, float *a, float *b, float *c, float *d) {
    int i = threadIdx.x;
    if (i<N) {
				__shared__ float C[M];
        C[i] = a[i]*b[i];
        __syncthreads();
        if (i<4) d[i] = C[i]+C[i+4];
    }
}
