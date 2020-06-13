#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define BYTE_TOTAL 25
#define ATTEMPTS 100

int main (void) {
//	printf("Starting HostToDevice Bytes vs. Time Data Collection.......\n");
	//  Initialize parameters
	const uint32_t BYTES[BYTE_TOTAL] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24};
	FILE *outFile;
	for (int i=0; i<BYTE_TOTAL; i++) {
//		printf("Beginning Byte Total 2^%i.......\n", i);
		size_t size = BYTES[i]*sizeof(float);
		//  Declare Host variables
		float *a;
		float *b;
		float *c;
		float *d;
		float *e;
		float *f;
		float *g;
		float *h;
		//  Declare Device variables
		float *d_a;
		float *d_b;
		float *d_c;
		float *d_d;
		float *d_e;
		float *d_f;
		float *d_g;
		float *d_h;
		//  Allocate Host variables
		cudaHostAlloc((void**)&a, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&b, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&c, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&d, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&e, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&f, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&g, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&h, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		//  Allocate Device variables
		cudaMalloc(&d_a, size);
		cudaMalloc(&d_b, size);
		cudaMalloc(&d_c, size);
		cudaMalloc(&d_d, size);
		cudaMalloc(&d_e, size);
		cudaMalloc(&d_f, size);
		cudaMalloc(&d_g, size);
		cudaMalloc(&d_h, size);
		//	Get the GPU Pointers
		cudaHostGetDevicePointer(&d_a, a, 0);
		cudaHostGetDevicePointer(&d_b, b, 0);
		cudaHostGetDevicePointer(&d_c, c, 0);
		cudaHostGetDevicePointer(&d_d, d, 0);
		cudaHostGetDevicePointer(&d_e, e, 0);
		cudaHostGetDevicePointer(&d_f, f, 0);
		cudaHostGetDevicePointer(&d_g, g, 0);
		cudaHostGetDevicePointer(&d_h, h, 0);
		//  Set Host variables
		for (uint32_t j=0; j<BYTES[j]; j++) {
			int n0 = rand()%1000000;
			int n1 = rand()%1000000;
			int n2 = rand()%1000000;
			int n3 = rand()%1000000;
			int n4 = rand()%1000000;
			int n5 = rand()%1000000;
			int n6 = rand()%1000000;
			int n7 = rand()%1000000;
			int n8 = rand()%1000000;
			int n9 = rand()%1000000;
			int n10 = rand()%1000000;
			int n11 = rand()%1000000;
			int n12 = rand()%1000000;
			int n13 = rand()%1000000;
			int n14 = rand()%1000000;
			int n15 = rand()%1000000;
			a[j] = n0*n1;
			b[j] = n2*n3;
			c[j] = n4*n5;
			d[j] = n5*n6;
			e[j] = n7*n8;
			f[j] = n9*n10;
			g[j] = n11*n12;
			h[j] = n13*n14;
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
		cudaMemcpy(d_c, c, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_d, d, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_e, e, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_f, f, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_g, g, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_h, h, size, cudaMemcpyHostToDevice);
		cudaEventRecord(stop);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&milli, start, stop);
		//	Write Data to File
		int iBuf = i+3;
		char fn[50] = "rawData_bytes_8a_";
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
		cudaFreeHost(c);
		cudaFreeHost(d);
		cudaFreeHost(e);
		cudaFreeHost(f);
		cudaFreeHost(g);
		cudaFreeHost(h);
		//  Deallocate Device variables
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		cudaFree(d_d);
		cudaFree(d_e);
		cudaFree(d_f);
		cudaFree(d_g);
		cudaFree(d_h);
	}
	return 0;
}
