#include <stdio.h>
#include <stdlib.h>
#include "nanoTime.h"

#define RANGE 12

int main() {
	int N[RANGE];
	for (int i=0; i<RANGE; i++) N[i] = 1<<i;

	for (int R=0; R<RANGE; R++) {
		struct timespec vartime;
		float time_elapsed_nanos;

		float **A;
		float **B;
		float **C;

		A = (float**)malloc(sizeof(float*)*N[R]);
		A[0] = (float*)malloc(sizeof(float)*N[R]*N[R]);
		B = (float**)malloc(sizeof(float*)*N[R]);
		B[0] = (float*)malloc(sizeof(float)*N[R]*N[R]);
		C = (float**)malloc(sizeof(float*)*N[R]);
		C[0] = (float*)malloc(sizeof(float)*N[R]*N[R]);

		for (int i=0; i<N[R]; i++) {
			A[i] = (*A + N[R]*i);
			B[i] = (*B + N[R]*i);
			C[i] = (*C + N[R]*i);
		}

		//	Assign values
		//		printf("Assign values.....");
		for (int i=0; i<N[R]; i++) {
			for (int j=0; j<N[R]; j++) {
				A[i][j] = rand()%(1<<2);
				B[i][j] = rand()%(1<<2);
				C[i][j] = 0;
			}
		}

		vartime = timer_start();	
		for (int i=0; i<N[R]; i++) {
			for (int j=0; j<N[R]; j++) {
				C[i][j] = A[i][j]+B[i][j];
			}
		}
		time_elapsed_nanos = timer_end(vartime);
		float time_elapsed_micro = time_elapsed_nanos/1000;
		printf("time = %f us     ", time_elapsed_micro);

		vartime = timer_start();	
		for (int j=0; j<N[R]; j++) {
			for (int i=0; i<N[R]; i++) {
				C[i][j] = A[i][j]+B[i][j];
			}
		}
		time_elapsed_nanos = timer_end(vartime);
		time_elapsed_micro = time_elapsed_nanos/1000;
		printf("time = %f us\n", time_elapsed_micro);

		free(A);
		free(B);
		free(C);
	}

	return 0;
}
