#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <ctime>

#define SM (64/sizeof(double))

#define ITER 1
#define RANGE 2080

void multiply2(int N, double **A, double **B, double **C);

int main() {
	for (int N=2; N<RANGE; N+=2) {
		double **A;
		double **B;
		double **C;

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

		//	Run algorithm
		std::clock_t start;
		double duration;
		start = std::clock();
		for (int k=0; k<ITER; k++) 
			multiply2(N,A,B,C);
		duration = (std::clock() - start) / (double)CLOCKS_PER_SEC;
		double flop = (2*N*N*N) / duration;

		free(A);
		free(B);
		free(C);

		std::fstream fot;
		fot.open("theData_cpu.txt", std::fstream::out | std::fstream::app);
		fot << N << "," << duration << "," << flop << std::endl;
		fot.close();

		std::cout << "Finished " << N << std::endl;
	}

	return 0;
}

void multiply2(int N, double **A, double **B, double **C) {
	double *Bcolj;
	Bcolj = (double*)malloc(sizeof(double)*N);
	for (int j=0; j<N; j++) {
		for (int k=0; k<N; k++)
			Bcolj[k] = B[k][j];
		for (int i=0; i<N; i++) {
			double s = 0;
			for (int k=0; k<N; k++)
				s += A[i][k] * Bcolj[k];
			C[j][i] = s;
		}
	}
}
