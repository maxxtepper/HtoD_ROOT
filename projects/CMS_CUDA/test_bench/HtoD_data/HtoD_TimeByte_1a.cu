#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define BYTE_MAX 28
#define ATTEMPTS 100

#define PINNED 0

const uint32_t BYTES[BYTE_MAX] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26, 1<<27};
const uint32_t BYTE_TOTAL[4] = {28, 27, 26, 25};

int main(int argc, char *argv[]) {
	if (argc != 3) {
		printf("Usage: HtoD_TimeByte_1a array iteration\n");
		printf("Example: HtoD_TimeByte_1a 1 1000\n");
		return 0;
	}
	int array = atoi(argv[1]);
	int iterations = atoi(argv[2]);
	printf("Starting HostToDevice Bytes vs. Time Data Collection.......\n\n");
	printf("Number of Arrays: %d\n............\n", array);
	for (int run=0; run<iterations; run++) {
		printf("\r%d/%d", run+1, iterations);
		fflush(stdout);
		//  Initialize parameters
		FILE *outFile;
		for (int i=(0+array-1); i<BYTE_TOTAL[array]; i++) {
			size_t size = BYTES[i]*sizeof(float);
			//  Declare Host variables
			float *a;
			//  Declare Device variables
			float *d_a;

			if (PINNED) {
				//  Allocate Host variables
				cudaMallocHost((void**)&a, size);
			} else {
				//  Allocate Host variables
				a = (float*)malloc(size);
			}
			//  Allocate Device variables
			cudaMalloc((void**)&d_a, size);
			//	Get the GPU Pointers
			//	cudaHostGetDevicePointer(&d_a, a, 0);
			//  Set Host variables
			for (uint32_t j=0; j<BYTES[j]; j++) {
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
			
			if (PINNED) {
				//  Deallocate Host variables
				cudaFreeHost(a);
			} else {
				//  Deallocate Host variables
				free(a);
			}
			//  Deallocate Device variables
			cudaFree(d_a);
		}
	}
	printf("\n............\n\n");
	printf("Complete!!\n");
	return 0;
}
