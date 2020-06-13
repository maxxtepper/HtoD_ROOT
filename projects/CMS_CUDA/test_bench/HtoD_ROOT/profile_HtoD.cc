#include <iostream>
#include <fstream>
#include <cassert>
#include <TFile.h>
#include <TTree.h>
#include <TChain.h>
#include <TCanvas.h>
#include <TProfile.h>
#include <TText.h>
#include <TMath.h>
#include <stdlib.h> 
#include <stdio.h>
#include <string>
#include <sstream>

#define BYTE_MAX 28

const uint32_t BYTES[BYTE_MAX] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26, 1<<27};

int main(int argc, char *argv[]) {
	if (argc != 3) {
		printf("Usage: ./profile_HtoD card memory\n\
				card = \"gtx\" or \"quadro\"\n\
				memory = \"pinned\" or \"paged\"\n");
		return EXIT_FAILURE;
	}

	std::string card = std::string(argv[1]);
	std::string memory = std::string(argv[2]);

	std::string pwd;
	char cwd[1024];
	if (getcwd(cwd,sizeof(cwd)) != NULL)
		pwd = cwd;
	else {
		std::cout << "ERROR: Could not find cwd!\n";
		return -1;
	}

	std::string infileName, outfileName;
	std::string inF, outF;
	std::string inPref, outPref;
	std::string byte;

	inPref = pwd + "/raw_root/";
	outPref = pwd + "/profile_root/";
	outF = "profile_" + card + "_HtoD_" + memory + ".root";
	outfileName = outPref + outF;

	TFile *outfile;
	outfile = TFile::Open(outfileName.c_str(), "RECREATE");
		
	//	Setup profiles
	std::string pFLat_id = "profLatency_" + memory;
	std::string pFThr_id = "profThroughput_" + memory;
	std::string pFLat_name = "Host to Device Latency (Time vs. Bits)";
	std::string pFThr_name = "Host to Device Throughput (Rate vs. Bits)";

	TProfile *profLat = new TProfile(pFLat_id.c_str(), pFLat_name.c_str(), BYTE_MAX, 0, BYTE_MAX, 0.001, 1000);
	TProfile *profThr = new TProfile(pFThr_id.c_str(), pFThr_name.c_str(), BYTE_MAX, 0, BYTE_MAX, 0    , 1000);
	
	profLat->SetTitle("Host to Device Latency (Time vs. Bits)");
	profLat->GetXaxis()->SetTitle("Bits");
	profLat->GetYaxis()->SetTitle("Time (milliseconds)");
	profLat->SetLineWidth(2);

	profThr->SetTitle("Host to Device Throughput (Rate vs. Bits");
	profThr->GetXaxis()->SetTitle("Bits");
	profThr->GetYaxis()->SetTitle("Rate (GB/s)");
	profThr->SetLineWidth(2);

	//	Add all the trees to it
	for (int i=0; i<BYTE_MAX; i++) {
		std::string bytes;
		bytes = std::to_string(i);
		std::string ch_name = "rawTree_" + bytes;
		TChain *chain = new TChain(ch_name.c_str());

		inF = "raw_" + card + "_HtoD_" + memory + ".root";
		infileName = inPref + inF;
		std::ifstream fin;
		fin.open(infileName.c_str());
		if (!fin.fail()) {
			fin.close();
			chain->Add(infileName.c_str());
		} else break;

		Float_t time = 0;
		Float_t rate = 0;

		chain->SetBranchAddress("time", &time);
		chain->SetBranchAddress("rate", &rate);

		Float_t bits = TMath::Power(2,i)*sizeof(float)*8;
		
		Int_t nentries = chain->GetEntries();

		for (Int_t j=0; j<nentries; j++) {
			chain->GetEntry(j);
			profLat->Fill(i,time);
			profThr->Fill(i,rate);
		}
	}
	profLat->Write();
	profThr->Write();
	outfile->Close();
}
