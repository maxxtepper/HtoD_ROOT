#include <stdio.h>
#include <stdlib.h>

int main() {
	unsigned int N = 450000000;
	unsigned int bytes = N*sizeof(double);
	//	Host Initialization
	double *h_a;
	h_a = (double*)malloc(bytes);
	for (unsigned int i=0; i<N; i++)
		h_a[i] = 2.0f;

	//	Device Initialization
	double *d_a;
	cudaMalloc(&d_a, bytes);
	
	//	Event Initialization
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milli = 0;

	cudaEventRecord(start,0);
	cudaMemcpy(d_a,h_a,bytes,cudaMemcpyHostToDevice);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);

	printf("%f ms\n",milli);

	//	Cleanup
	free(h_a);
	cudaFree(d_a);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);

	return 0;
}
