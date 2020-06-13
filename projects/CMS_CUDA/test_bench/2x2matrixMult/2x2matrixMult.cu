#include <stdio.h>

#define DIM_0 2
#define DIM_1 2
#define DIM_2 2

__global__ void product(int N, float *A[N][N], float *B[N][N], float *C[N][N][N], float *D[N][N]) {
	int i = threadIdx.x;
	int j = threadIdx.y;
	int k = threadIdx.z;

	if (i<N && j<N) {
		__shared__ C[i][j][k] = A[i][k]*B[k][j];
	}
	////////////////
	__syncthreads();
	////////////////
	for (int m=0; m<N; m++) {
		D[i][j]+=C[i][j][m];
	}
}

int main(void) {
	//	Declare initial parameters
	int N = DIM_0*DIM_1;
	size_t size = N*sizeof(float);
	//	Create Host variables
	float *mA, *mB, *mC, *mD;
	//	Create Device variables
	float *d_mA, *d_mB, *d_mC, *d_mD;
	//	Allocate memory for Host
	mA = (float*)malloc(size);
	mB = (float*)malloc(size);
	mC = (float*)malloc(size*2);
	mD = (float*)malloc(size);
	//	Set Host values
	for (int i=0; i<4; i++) {
		mA[i] = (i+1);
		mB[i] = (i+5);
	}
	//	Allocate memory for Device
	cudaMalloc(&d_mA, size);
	cudaMalloc(&d_mB, size);
	cudaMalloc(&d_mC, size*2);
	cudaMalloc(&d_mD, size);
	//	Set Device values
	cudaMemcpy(d_mA, mA, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_mB, mB, size, cudaMemcpyHostToDevice);
	//	Send kernel to Device
	dim3 threadsPerBlock(DIM_0, DIM_1, DIM_2);
	product<<<1, threadsPerBlock>>>(size*2, d_mA, d_mB, d_mC, d_mD);
	//	Retrieve Device variables
	cudaMemcpy(mD, d_mD, size, cudaMemcpyDeviceToHost);
	//	Print results
	printf("%f    %f\n", mD[0], mD[1]);
	printf("%f    %f\n", mD[2], mD[3]);;
	return 0;
}

