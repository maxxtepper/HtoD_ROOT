#include <stdio.h>
#include "nanoTime.h"

__global__ void product_sumAB(int N, float *a, float *b, float *c, float *d, float *e);

int main (void) {
    //  Initialize parameters
		printf("2x2matrixMult_v1\n");
    int DIM_0 = 2;
    int DIM_1 = 2;
    int N = DIM_0*DIM_1;
    size_t size = N*sizeof(float);
    //  Declare Host variables
    float *a, *b, *c, *d, *e;
    //  Declare Device variables
    float *d_a, *d_b, *d_c, *d_d, *d_e;
    //  Allocate Host variables
    a = (float*)malloc(size*2);
    b = (float*)malloc(size*2);
    c = (float*)malloc(size*2);
    d = (float*)malloc(size);
    e = (float*)malloc(size);
    //  Allocate Device variables
    cudaMalloc(&d_a, size*2);
    cudaMalloc(&d_b, size*2);
    cudaMalloc(&d_c, size*2);
    cudaMalloc(&d_d, size);
    cudaMalloc(&d_e, size);
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
    //  Set Device variables
    cudaMemcpy(d_a, a, size*2, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size*2, cudaMemcpyHostToDevice);
    //cudaMemcpy(d_c, c, size, cudaMemcpyHostToDevice);
    //cudaMemcpy(d_d, d, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_e, e, size, cudaMemcpyHostToDevice);
    //  Initialize Host Event Handeling
    struct timespec vartime;
    float time_elapsed_nanos;
    //  Initialize Device Event Handeling
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    /////////////////////////////////////////////////////////
    ////  GPU Calculation  //////////////////////////////////
		float milli = 0;
		float micro = 0;
//		for (int i=0; i<100000; i++) {
			//  Kernel 0 (Products and Sums)
			cudaEventRecord(start);
			product_sumAB<<<1,4>>>(N, d_a, d_b, d_c, d_d, d_e);
			cudaEventRecord(stop);
			cudaEventSynchronize(stop);
			//  Device Event Results
			cudaEventElapsedTime(&milli, start, stop);
			micro += (milli*1000);
//		}
//		micro /= 100000;
    //  Kernels Complete
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //  Get Device variables
    cudaMemcpy(e, d_e, size, cudaMemcpyDeviceToHost);
    //  Results (GPU)
    printf("GPU Calculation:\n");
    //printf("%f     %f\n", e[0], e[1]);
    //printf("%f     %f\n", e[2], e[3]);
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
    //free(c);
    //free(d);
    free(e);
    //  Deallocate Device variables
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaFree(d_d);
    cudaFree(d_e);
    return 0;
}

__global__ void product_sumAB(int N, float *a, float *b, float *c, float *d, float *e) {
    int i = threadIdx.x;
    if (i<N) {
        c[i] = a[i]*b[i];
        d[i] = a[i+4]*b[i+4];
        e[i] = c[i]+d[i];
    }
}
