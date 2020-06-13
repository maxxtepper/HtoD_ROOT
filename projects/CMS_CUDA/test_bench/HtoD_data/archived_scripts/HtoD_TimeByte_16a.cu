#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define BYTE_TOTAL 24
#define ATTEMPTS 100

int main (void) {
//	printf("Starting HostToDevice Bytes vs. Time Data Collection.......\n");
	//  Initialize parameters
	const uint32_t BYTES[BYTE_TOTAL] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23};
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
		float *aa;
		float *ba;
		float *ca;
		float *da;
		float *ea;
		float *fa;
		float *ga;
		float *ha;
		//  Declare Device variables
		float *d_a;
		float *d_b;
		float *d_c;
		float *d_d;
		float *d_e;
		float *d_f;
		float *d_g;
		float *d_h;
		float *d_aa;
		float *d_ba;
		float *d_ca;
		float *d_da;
		float *d_ea;
		float *d_fa;
		float *d_ga;
		float *d_ha;
		//  Allocate Host variables
		cudaHostAlloc((void**)&a, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&b, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&c, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&d, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&e, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&f, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&g, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&h, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&aa, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&ba, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&ca, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&da, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&ea, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&fa, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&ga, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		cudaHostAlloc((void**)&ha, size, cudaHostAllocWriteCombined | cudaHostAllocMapped);
		//  Allocate Device variables
		cudaMalloc(&d_a, size);
		cudaMalloc(&d_b, size);
		cudaMalloc(&d_c, size);
		cudaMalloc(&d_d, size);
		cudaMalloc(&d_e, size);
		cudaMalloc(&d_f, size);
		cudaMalloc(&d_g, size);
		cudaMalloc(&d_h, size);
		cudaMalloc(&d_aa, size);
		cudaMalloc(&d_ba, size);
		cudaMalloc(&d_ca, size);
		cudaMalloc(&d_da, size);
		cudaMalloc(&d_ea, size);
		cudaMalloc(&d_fa, size);
		cudaMalloc(&d_ga, size);
		cudaMalloc(&d_ha, size);
		//	Get the GPU Pointers
		cudaHostGetDevicePointer(&d_a, a, 0);
		cudaHostGetDevicePointer(&d_b, b, 0);
		cudaHostGetDevicePointer(&d_c, c, 0);
		cudaHostGetDevicePointer(&d_d, d, 0);
		cudaHostGetDevicePointer(&d_e, a, 0);
		cudaHostGetDevicePointer(&d_f, b, 0);
		cudaHostGetDevicePointer(&d_g, c, 0);
		cudaHostGetDevicePointer(&d_h, d, 0);
		cudaHostGetDevicePointer(&d_aa, aa, 0);
		cudaHostGetDevicePointer(&d_ba, ba, 0);
		cudaHostGetDevicePointer(&d_ca, ca, 0);
		cudaHostGetDevicePointer(&d_da, da, 0);
		cudaHostGetDevicePointer(&d_ea, ea, 0);
		cudaHostGetDevicePointer(&d_fa, fa, 0);
		cudaHostGetDevicePointer(&d_ga, ga, 0);
		cudaHostGetDevicePointer(&d_ha, ha, 0);
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
			int n0a = rand()%1000000;
			int n1a = rand()%1000000;
			int n2a = rand()%1000000;
			int n3a = rand()%1000000;
			int n4a = rand()%1000000;
			int n5a = rand()%1000000;
			int n6a = rand()%1000000;
			int n7a = rand()%1000000;
			int n8a = rand()%1000000;
			int n9a = rand()%1000000;
			int n10a = rand()%1000000;
			int n11a = rand()%1000000;
			int n12a = rand()%1000000;
			int n13a = rand()%1000000;
			int n14a = rand()%1000000;
			int n15a = rand()%1000000;
			a[j] = n0*n1;
			b[j] = n2*n3;
			c[j] = n4*n5;
			d[j] = n5*n6;
			e[j] = n7*n8;
			f[j] = n9*n10;
			g[j] = n11*n12;
			h[j] = n13*n14;
			aa[j] = n0a*n1a;
			ba[j] = n2a*n3a;
			ca[j] = n4a*n5a;
			da[j] = n5a*n6a;
			ea[j] = n7a*n8a;
			fa[j] = n9a*n10a;
			ga[j] = n11a*n12a;
			ha[j] = n13a*n14a;
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
		cudaMemcpy(d_aa, aa, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_ba, ba, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_ca, ca, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_da, da, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_ea, ea, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_fa, fa, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_ga, ga, size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_ha, ha, size, cudaMemcpyHostToDevice);
		cudaEventRecord(stop);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&milli, start, stop);
		//	Write Data to File
		int iBuf = i+4;
		char fn[50] = "rawData_bytes_16a_";
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
		cudaFreeHost(aa);
		cudaFreeHost(ba);
		cudaFreeHost(ca);
		cudaFreeHost(da);
		cudaFreeHost(ea);
		cudaFreeHost(fa);
		cudaFreeHost(ga);
		cudaFreeHost(ha);
		//  Deallocate Device variables
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		cudaFree(d_d);
		cudaFree(d_e);
		cudaFree(d_f);
		cudaFree(d_g);
		cudaFree(d_h);
		cudaFree(d_aa);
		cudaFree(d_ba);
		cudaFree(d_ca);
		cudaFree(d_da);
		cudaFree(d_ea);
		cudaFree(d_fa);
		cudaFree(d_ga);
		cudaFree(d_ha);
	}
	return 0;
}
