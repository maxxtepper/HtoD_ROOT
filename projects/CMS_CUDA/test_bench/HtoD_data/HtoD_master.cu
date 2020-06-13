#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define BYTE_MAX 28
#define ATTEMPTS 100

#define PINNED 0

const uint32_t BYTES[BYTE_MAX] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26, 1<<27};

int main(int argc, char *argv[]) {
	//  Initialize parameters
	FILE *outFile;
	for (int i=0; i<28; i++) {
		size_t bytes = BYTES[i]*sizeof(float);
		//  Declare Host variables
		float *a;
		//  Declare Device variables
		float *d_a;
		//  Allocate Host variables
		if (PINNED) {
			cudaMallocHost((void**)&a, bytes);
		} else {
			a = (float*)malloc(size);
		}
		//  Allocate Device variables
		cudaMalloc(&d_a, bytes);
		//	Get the GPU Pointers
		//	cudaHostGetDevicePointer(&d_a, a, 0);
		//  Set Host variables
		for (uint32_t j=0; j<BYTES[i]; j++) {
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
		cudaMemcpy(d_a, a, bytes, cudaMemcpyHostToDevice);
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&milli, start, stop);
		cudaEventDestroy(start);
		cudaEventDestroy(stop);
		//	Write Data to File
		int iBuf = i;
		char fn[50] = "rawData_bytes_1a_";
		char s_byte[50];
		snprintf(s_byte, 50, "%i", iBuf);
		strcat(fn, s_byte);
		strcat(fn, ".txt");
		outFile = fopen(fn, "a");
		char buffer_0[50];
		snprintf(buffer_0, 50, "%f", milli);
		strcat(buffer_0, ",");
		fputs(buffer_0, outFile);
		char buffer_1[50];
		snprintf(buffer_1, 50, "%i", iBuf);
		strcat(buffer_1, "\n");
		fputs(buffer_1, outFile);
		fclose(outFile);
		//  Deallocate Host variables
		if (PINNED) {
			cudaFree(a);
		} else {
			free(a);
		}
		//  Deallocate Device variables
		cudaFree(d_a);
	}
	return 0;
}
