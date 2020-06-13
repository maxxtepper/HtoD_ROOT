#include <iostream>
#include <fstream>
#include <cassert>
#include <TFile.h>
#include <TTree.h>
#include <TChain.h>
#include <TMath.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <sstream>
#include "HtoD_master.h"

#define BYTE_MAX 28

const uint32_t BYTES[BYTE_MAX] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26, 1<<27};

void rawInput();

int main(int argc, char *argv[]) {
	//	Check input arguments
	if (argc!=4) {
		printf("Usage: ./HtoD_test card memory iterations\n\
				card = \"gtx\" or \"quadro\"\n\
				memory = \"pinned\" or \"paged\"\n\
				iterations = number of runs\n");
		return EXIT_FAILURE;
	}

	//	Extract input arguments
	std::string card = std::string(argv[1]);
	std::string memory = std::string(argv[2]);
	int iterations = std::atoi(argv[3]);
	bool pinned;
	if (memory == "pinned") pinned = true;
	else if (memory == "paged") pinned = false;

	//	Get pwd for file in/out
	std::string pwd;
	char cwd[1024];
	if (getcwd(cwd,sizeof(cwd)) != NULL)
		pwd = cwd;
	else {
		std::cout << "ERROR: Could not find cwd!\n";
		return -1;
	}

	//	Prepare file output
	std::string outfileName;
	std::string outPref;
	outPref = pwd + "/raw_root/";
	outfileName = outPref + "raw_" + card + "_HtoD_" + memory + ".root";

	//	Make a ROOT file
	TFile *outfile;
	outfile = TFile::Open(outfileName.c_str(), "RECREATE");

	//	Run Test for 2^0 - 2^27
	std::cout << "Starting HtoD 2^0 - 2^27 with " << memory << " " << card << " memory\n";
	for (int i=0; i<BYTE_MAX; i++) {
		std::cout << "working on 2^" << i << "....\n";
		Float_t time = 0;
		Float_t rate = 0;

		std::string rT_id   = "rawTree_" + std::to_string(i);
		std::string rT_name = "Raw Data of 2^" + std::to_string(i) + " Elements";
		TTree *rawT = new TTree(rT_id.c_str(),rT_name.c_str());

		rawT->Branch("time", &time, "time/F");
		rawT->Branch("rate", &rate, "rate/F");

		Float_t bytes = BYTES[i];
		Float_t bits = 0;

		for (int j=0; j<iterations; j++) {
			bits = bytes*sizeof(float)*8;
			time = HtoD(BYTES[i], pinned);
			rate = (bits*1e-6)/time;

			rawT->Fill();
		}
		rawT->Write();
	}
	outfile->Close();

	return 0;
}
