#include <stdio.h>
#include "nanoTime.h"

__global__ void productAB(int N, float *a, float *b, float *c);

__global__ void sumAB(int N, float *c, float *d);

__global__ void test(int N, float *c, float *d);

int main (void) {
		printf("2x2matrixMult_v0\n");
    //  Initialize parameters
		int N = 2<<12;
    size_t bytes = N*sizeof(float);
    //  Declare Host variables
    float *a, *b, *c, *d;
    //  Declare Device variables
    float *d_a, *d_b, *d_c, *d_d;
    //  Allocate Host variables
    a = (float*)malloc(bytes);
    b = (float*)malloc(bytes);
    c = (float*)malloc(bytes);
    d = (float*)malloc(bytes);
    //  Allocate Device variables
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);
    cudaMalloc(&d_d, bytes);
    //  Set Host variables
		for (int i=0; i<N; i++) {
			a[i] = 1.0f;
			b[i] = 5.0f;
		}
    //  Set Device variables
    cudaMemcpy(d_a, a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_d, d, bytes, cudaMemcpyHostToDevice);
    //  Initialize Host Event Handeling
    struct timespec vartime;
    float time_elapsed_nanos;
    //  Initialize Device Event Handeling
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    /////////////////////////////////////////////////////////
    ////  GPU Calculation  //////////////////////////////////

		dim3 threadsPerBlock(8,8);
		dim3 numBlocks(N/threadsPerBlock.x,N/threadsPerBlock.y);

		productAB<<<numBlocks,threadsPerBlock>>>(N, d_a, d_b, d_c);
		sumAB<<<1,4>>>(N, d_c, d_d);

		float milli0 = 0;
		float micro0 = 0;
		float milli1 = 0;
		float micro1 = 0;
		float milli2 = 0;
		float micro2 = 0;
		cudaStream_t stream0, stream1, stream2;
		cudaStreamCreate(&stream0);
		cudaStreamCreate(&stream1);
		cudaStreamCreate(&stream2);

		cudaEventRecord(start,stream0);
		productAB<<<numBlocks,threadsPerBlock,0,stream0>>>(N, d_a, d_b, d_c);
		cudaEventRecord(stop,stream0);
		cudaStreamSynchronize(stream0);
		cudaEventElapsedTime(&milli0, start, stop);
		micro0 = milli0*1000;

		cudaEventRecord(start,stream1);
		sumAB<<<32,100,0,stream1>>>(N, d_c, d_d);
		cudaEventRecord(stop,stream1);
		cudaStreamSynchronize(stream1);
		cudaEventElapsedTime(&milli1, start, stop);
		micro1 = milli1*1000;

		cudaEventRecord(start,stream2);
		test<<<1,4,0,stream2>>>(N, d_c, d_d);
		cudaEventRecord(stop,stream2);
		cudaStreamSynchronize(stream2);
		cudaEventElapsedTime(&milli2, start, stop);
		micro2 = (milli2*1000);

		cudaEventDestroy(start);
		cudaEventDestroy(stop);
		cudaStreamDestroy(stream0);
		cudaStreamDestroy(stream1);
		cudaStreamDestroy(stream2);

    vartime = timer_start();
		productAB<<<1,8>>>(N, d_a, d_b, d_c);
		sumAB<<<1,4>>>(N, d_c, d_d);
    time_elapsed_nanos = timer_end(vartime);
		float time_elapsed_micro = time_elapsed_nanos/1000;

    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //  Get Device variables
    cudaMemcpy(d, d_d, bytes, cudaMemcpyDeviceToHost);
    //  Results (GPU)
    printf("GPU Calculation:\n");
    //printf("%f     %f\n", d[0], d[1]);
    //printf("%f     %f\n", d[2], d[3]);
    printf("Kernel Prod Elapsed Time (microseconds): %f\n", micro0);
    printf("Kernel Sum  Elapsed Time (microseconds): %f\n", micro1);
    printf("Kernel Test Elapsed Time (microseconds): %f\n", micro2);
    /////////////////////////////////////////////////////////
    ////  CPU Calculation  //////////////////////////////////
    //vartime = timer_start();
    for (int i=0; i<8; i++) c[i] = a[i]*b[i];
    for (int i=0; i<4; i++) d[i] = c[i]+c[i+4];
    //time_elapsed_nanos = timer_end(vartime);
		//float time_elapsed_micro = time_elapsed_nanos/1000;
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////
    //  Results (CPU)
    //printf("CPU Calculation:\n");
    //printf("%f     %f\n", d[0], d[1]);
    //printf("%f     %f\n", d[2], d[3]);
    //printf("Elapsed Time (microseconds): %f\n", time_elapsed_micro);
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

__global__ void productAB(int N, float *a, float *b, float *c) {
    //int i = threadIdx.x;
		int i = (blockIdx.x*blockDim.x) + threadIdx.x;
		int j = (blockIdx.y*blockDim.y) + threadIdx.y;
    if (i<N) c[i] = a[i]*b[j];
}

__global__ void sumAB(int N, float *c, float *d) {
    int i = threadIdx.x;
    if (i<N) d[i] = c[i]+c[i+(N/2)];
}

__global__ void test(int N, float *c, float *d) {
    int i = threadIdx.x;
    if (i<N) d[i] = (1/(c[i]+3)); 
}
