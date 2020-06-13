#include <iostream>
#include "nanoTime.h"

#define NPAD (1<<25)
#define NODES (1<<6)

struct node {
	struct node *n;
	long int pad[NPAD];
};

int main() {
	//	Performance
	struct timespec vartime;
	double time_elapsed_nanos;

	//	Creation
	node *myNode[NODES];
	for (int i=0; i<NODES; i++) myNode[i] = new node();

	//	Link the List
	for (int i=0; i<NODES; i++)
		myNode[i]->n = myNode[i+1];
	myNode[NODES-1]->n = myNode[0];

	//	The Stuff
	int runs = 0;
	while (runs<1000) {
		node *now;
		now = myNode[0]->n;
		time_elapsed_nanos = 0;
		for (int i=0; i<NODES; i++) {
			vartime = timer_start();
			now = now->n;
			time_elapsed_nanos += timer_end(vartime);
		}
		time_elapsed_nanos /= NODES;
		std::cout << time_elapsed_nanos << std::endl;
		runs++;
	}

	//	Destruction
	for (int i=0; i<NODES; i++) delete myNode[i];
	return 0;
}
