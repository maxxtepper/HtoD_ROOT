#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define BYTE_TOTAL 27
#define ATTEMPTS 100

int main (void) {
//	printf("Starting HostToDevice Bytes vs. Time Data Collection.......\n");
	//  Initialize parameters
	const uint32_t BYTES[BYTE_TOTAL] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26};
	FILE *outFile;
	for (int i=0; i<BYTE_TOTAL; i++) {
//		printf("Beginning Byte Total 2^%i.......\n", i);
		size_t size = BYTES[i]*sizeof(float);
		//  Declare Host variables
		float *a;
		float *b;
		//  Declare Device variables
		float *d_a;
		float *d_b;
		//  Allocate Host variables
		cudaHostAlloc((void**)&a, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&b, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		//  Allocate Device variables
		cudaMalloc(&d_a, size);
		cudaMalloc(&d_b, size);
		//	Get the GPU Pointers
		cudaHostGetDevicePointer(&d_a, a, 0);
		cudaHostGetDevicePointer(&d_b, b, 0);
		//  Set Host variables
		for (uint32_t j=0; j<BYTES[j]; j++) {
			int n0 = rand()%1000000;
			int n1 = rand()%1000000;
			int n2 = rand()%1000000;
			int n3 = rand()%1000000;
			a[j] = n0*n1;
			b[j] = n2*n3;
		}
		//  Initialize Device Event Handeling
		float milli = 0;
		cudaEvent_t start, stop;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);
		/////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////
		//  Set Device variables
		cudaEventRecord(start);
		cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
		cudaEventRecord(stop);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&milli, start, stop);
		//	Write Data to File
		int iBuf = i+1;
		char fn[50] = "rawData_bytes_2a_";
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
		cudaFreeHost(a);
		cudaFreeHost(b);
		//  Deallocate Device variables
		cudaFree(d_a);
		cudaFree(d_b);
	}
	return 0;
}
