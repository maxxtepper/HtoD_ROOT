#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "HtoD_master.h"

extern float HtoD(const uint32_t dim, bool pinned) {
	//  Initialize parameters
	size_t size = dim*sizeof(float);
	//  Declare Host variables
	float *a;
	//  Declare Device variables
	float *d_a;
	//  Allocate Host variables
	if (pinned)
		cudaMallocHost((void**)&a, size);
	else
		a = (float*)malloc(size);
	//  Allocate Device variables
	cudaMalloc((void**)&d_a, size);
	//  Set Host variables
	for (uint32_t j=0; j<dim; j++) {
		int n0 = rand()%1000000;
		int n1 = rand()%1000000;
		a[j] = n0*n1;
	}
	//  Initialize Device Event Handeling
	cudaFree(0);
	float milli = 0;
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//  Set Device variables
	cudaEventRecord(start, 0);
	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli, start, stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	//  Deallocate Host variables
	if (pinned)
		cudaFreeHost(a);
	else
		free(a);
	//  Deallocate Device variables
	cudaFree(d_a);
	return milli;
}
