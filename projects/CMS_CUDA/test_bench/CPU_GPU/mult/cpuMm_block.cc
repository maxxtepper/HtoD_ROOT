#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <ctime>
#include "nanoTime.h"

#define RANGE 512
#define HALF 100

#define min(x,y) ((x<y) ? x:y)

int main() {
	//	The Setup
	double BlockSize[250];
	for (int i=0, j=2; i<250; i++, j+=2) BlockSize[i] = j;
	struct timespec vartime;
	float time_elapsed_nanos;

	//	The Block Size Loop
	for (int indB=0; indB<250; indB++) {
		//	The NxN Matrix loop
		for (int N=2; N<HALF; N+=2) {
			//	Creation
			double **A;
			double **B;
			double **C;

			//	Allocation
			A = (double**)malloc(sizeof(double*)*N);
			A[0] = (double*)malloc(sizeof(double)*N*N);
			B = (double**)malloc(sizeof(double*)*N);
			B[0] = (double*)malloc(sizeof(double)*N*N);
			C = (double**)malloc(sizeof(double*)*N);
			C[0] = (double*)malloc(sizeof(double)*N*N);

			for (int i=0; i<N; i++) {
				A[i] = (*A + N*i);
				B[i] = (*B + N*i);
				C[i] = (*C + N*i);
			}

			//	Assign values
			for (int i=0; i<N; i++) {
				for (int j=0; j<N; j++) {
					A[i][j] = rand()%(1<<2);
					B[i][j] = rand()%(1<<2);
					C[i][j] = 0;
				}
			}

			//	The Process
		vartime = timer_start();	
			for(int i1=0; i1<(N/BlockSize[indB]); ++i1) 
				for(int j1=0; j1<(N/BlockSize[indB]); ++j1)
					for(int k1=0; k1<(N/BlockSize[indB]); ++k1)
						for(int i=i1; i<min(i1+BlockSize[indB]-1,N); ++i)
							for(int j=j1; j<min(j1+BlockSize[indB]-1,N); ++j)
								for(int k=k1; k<min(k1+BlockSize[indB]-1,N); ++k)
									C[i][j] = C[i][j] + A[i][k] * B[k][j];
		time_elapsed_nanos = timer_end(vartime);
		float time_elapsed= time_elapsed_nanos/1000000000;
		double flop = (2*N*N*N) / time_elapsed;

			//	Cleanup
			free(A[0]);
			free(A);
			free(B[0]);
			free(B);
			free(C[0]);
			free(C);

			//	Save Data
			std::fstream fot;
			fot.open("theData_cpu_block.txt", std::fstream::out | std::fstream::app);
			fot << N << "," << BlockSize[indB] << "," << time_elapsed << "," << flop << std::endl;
			fot.close();

			std::cout << "Done..." << N << std::endl;
		}

		for (int N=HALF; N<RANGE; N+=2) {
			//	Creation
			double **A;
			double **B;
			double **C;

			//	Allocation
			A = (double**)malloc(sizeof(double*)*N);
			A[0] = (double*)malloc(sizeof(double)*N*N);
			B = (double**)malloc(sizeof(double*)*N);
			B[0] = (double*)malloc(sizeof(double)*N*N);
			C = (double**)malloc(sizeof(double*)*N);
			C[0] = (double*)malloc(sizeof(double)*N*N);

			for (int i=0; i<N; i++) {
				A[i] = (*A + N*i);
				B[i] = (*B + N*i);
				C[i] = (*C + N*i);
			}

			//	Assign values
			for (int i=0; i<N; i++) {
				for (int j=0; j<N; j++) {
					A[i][j] = rand()%(1<<2);
					B[i][j] = rand()%(1<<2);
					C[i][j] = 0;
				}
			}

			//	The Process
			std::clock_t start;
			double duration;
			start = std::clock();
			for(int i1=0; i1<(N/BlockSize[indB]); ++i1) 
				for(int j1=0; j1<(N/BlockSize[indB]); ++j1)
					for(int k1=0; k1<(N/BlockSize[indB]); ++k1)
						for(int i=i1; i<min(i1+BlockSize[indB]-1,N); ++i)
							for(int j=j1; j<min(j1+BlockSize[indB]-1,N); ++j)
								for(int k=k1; k<min(k1+BlockSize[indB]-1,N); ++k)
									C[i][j] = C[i][j] + A[i][k] * B[k][j];
			duration = (std::clock() - start) / (double)CLOCKS_PER_SEC;
			double flop = (2*N*N*N) / duration;

			//	Cleanup
			free(A[0]);
			free(A);
			free(B[0]);
			free(B);
			free(C[0]);
			free(C);

			//	Save Data
			std::fstream fot;
			fot.open("theData_cpu_block.txt", std::fstream::out | std::fstream::app);
			fot << N << "," << BlockSize[indB] << "," << duration << "," << flop << std::endl;
			fot.close();

			std::cout << "Done..." << N << std::endl;
		}
	}

	return 0;
}
