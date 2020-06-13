// nvcc 037 ssymm .c -lcublas
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#define IDX2C(i,j,ld) (((j)*(ld))+(i))
#define m 333 // a - mxm matri
#define n 333 // b,c - mxn matrices
int main (void) {
	cudaError_t cudaStat ; // cudaMalloc status
	cublasStatus_t stat ; // CUBLAS functions status
	cublasHandle_t handle ; // CUBLAS context
	int i,j; // i-row ind. , j- column ind.
	float * a; // mxm matrix a on the host
	float * b; // mxn matrix b on the host
	float * c; // mxn matrix c on the host
	a = (float*)malloc(m*m*sizeof(float)); // host memory for a
	b = (float*)malloc(m*n*sizeof(float)); // host memory for b
	c = (float*)malloc(m*n*sizeof(float)); // host memory for c
	// define the lower triangle of an mxm symmetric matrix a in
	// lower mode column by column
	int ind = 11; // a:
	for(j=0; j<m; j++){ // 11
		for(i=0; i<m; i++){ // 12 ,17
			if(i >= j){ // 13 ,18 ,22
				a[IDX2C(i,j,m)]=(float)ind++; // 14 ,19 ,23 ,26
			} // 15 ,20 ,24 ,27 ,29
		} // 16 ,21 ,25 ,28 ,30 ,31
	}
	// print the lower triangle of a row by row
//	printf (" lower triangle of a:\n");
	for (i=0;i<m;i ++){
		for (j=0;j<m;j ++){
//			if(i >=j)
//				printf (" %5.0f",a[ IDX2C (i,j,m )]);
		}
//		printf ("\n");
	}
	// define mxn matrices b,c column by column
	ind =11; // b,c:
	for(j=0;j<n;j ++){ // 11 ,17 ,23 ,29
		for(i=0;i<m;i ++){ // 12 ,18 ,24 ,30
			b[ IDX2C (i,j,m )]=( float )ind; // 13 ,19 ,25 ,31
			c[ IDX2C (i,j,m )]=( float )ind; // 14 ,20 ,26 ,32
			ind ++; // 15 ,21 ,27 ,33
		} // 16 ,22 ,28 ,34
	}
	// print b(=c) row by row
//	printf ("b(=c):\n");
	for (i=0;i<m;i ++){
		for (j=0;j<n;j ++){
//			printf (" %5.0f",b[ IDX2C (i,j,m )]);
		}
//		printf ("\n");
	}
	// on the device
	float * d_a; // d_a - a on the device
	float * d_b; // d_b - b on the device
	float * d_c; // d_c - c on the device
	cudaStat = cudaMalloc (( void **)& d_a ,m*m* sizeof (*a)); // device
	// memory alloc for a
	cudaStat = cudaMalloc (( void **)& d_b ,m*n* sizeof (*b)); // device
	// memory alloc for b
	cudaStat = cudaMalloc (( void **)& d_c ,m*n* sizeof (*c)); // device
	// memory alloc for c
	stat = cublasCreate (& handle ); // initialize CUBLAS context
	// copy matrices from the host to the device
	stat = cublasSetMatrix (m,m, sizeof (*a) ,a,m,d_a ,m); //a -> d_a
	stat = cublasSetMatrix (m,n, sizeof (*b) ,b,m,d_b ,m); //b -> d_b
	stat = cublasSetMatrix (m,n, sizeof (*c) ,c,m,d_c ,m); //c -> d_c
	float al = 1.0f; // al =1
	float bet = 1.0f; // bet =1
	// symmetric matrix - matrix multiplication :
	// d_c = al*d_a *d_b + bet *d_c ; d_a - mxm symmetric matrix ;
	// d_b ,d_c - mxn general matrices ; al ,bet - scalars

	float milli = 0;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
	stat=cublasSsymm(handle,CUBLAS_SIDE_LEFT,CUBLAS_FILL_MODE_LOWER,
			m,n,&al,d_a,m,d_b,m,&bet,d_c,m);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milli,start,stop);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	float micro = milli*1000;

	stat = cublasGetMatrix (m,n, sizeof (*c) ,d_c ,m,c,m); // d_c -> c
//	printf ("c after Ssymm :\n"); // print c after Ssymm
	for(i=0;i<m;i ++){
		for(j=0;j<n;j ++){
//			printf (" %7.0f",c[ IDX2C (i,j,m )]);
		}
//		printf ("\n");
	}
	printf("\ntime = %f us\n",micro);
	cudaFree (d_a ); // free device memory
	cudaFree (d_b ); // free device memory
	cudaFree (d_c ); // free device memory
	cublasDestroy ( handle ); // destroy CUBLAS context
	free (a); // free host memory
	free (b); // free host memory
	free (c); // free host memory
	return EXIT_SUCCESS ;
}
