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

void profileTimeByte_all() {
	std::string infileName, outfileName;
	std::string inF, outF;
	std::string inPref, outPref;
	std::string byte;

	std::string aList[5] = {"1a", "2a", "4a", "8a", "16a"};
	
	inPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/raw_root_files/";
	outPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/profile_root_files/";

	std::string byte_label[27] = {"4","8","16","32","64","128","256","512",
		"1K","2K","4K","8K","16K","32K","64K","128K", "256K","512K","1M","2M",
		"4M","8M","16M","32M","64M","128M","256M"};
	
	int iBuf = 0;
		
//	TCanvas *c0 = new TCanvas("c0", "All profLat", 1);
//	TCanvas *c1 = new TCanvas("c1", "All profThr", 1);

	for (int k=0; k<5; k++) {
		outF = "profile_bytes_" + aList[k] + ".root";
		outfileName = outPref + outF;
		TFile *outfile;
		outfile = TFile::Open(outfileName.c_str(), "RECREATE");

		TChain *chain = new TChain("rawByteTimes");

		for (int i=iBuf; ;i++) {
			byte = std::to_string(i);
			inF = "rawData_bytes_" + aList[k] + "_" + byte + ".root";
			infileName = inPref + inF;
			ifstream fin;
			fin.open(infileName.c_str());
			if (!fin.fail()) {
				fin.close();
				std::cout << "Adding file " << inF << std::endl;
				chain->Add(infileName.c_str());
			} else break;
		}

		iBuf++;

		Float_t time = 0;
		Float_t bytesF = 0;
		Float_t rate = 0;

		chain->SetBranchAddress("time", &time);
		chain->SetBranchAddress("bytesF", &bytesF);
		chain->SetBranchAddress("rate", &rate);

		TProfile *profLat = new TProfile("profLat", "CPU to GPU Latency (Time vs. Bits)", (28-k), 0, (28-k), 0.001, 5000);
		TProfile *profThr = new TProfile("profThr", "CPU to GPU Throughput (Rate vs. Bits)", (28-k), 0, (28-k), 0, 5000);
		
		Int_t nentries = chain->GetEntries();

		for (Int_t i=0; i<nentries; i++) {
			chain->GetEntry(i);
			profLat->Fill(bytesF, time);
			profThr->Fill(bytesF, rate);
		}
		
		profLat->SetTitle("CPU to GPU Latency (Time vs. Bits)");
		profLat->GetXaxis()->SetTitle("Bits");
		profLat->GetYaxis()->SetTitle("Time (milliseconds)");
		profLat->SetLineWidth(2);

		profThr->SetTitle("CPU to GPU Throughput (Rate vs. Bits");
		profThr->GetXaxis()->SetTitle("Bits");
		profThr->GetYaxis()->SetTitle("Rate (GB/s)");
		profThr->SetLineWidth(2);
	/*	
		TAxis *xaxLat;
		TAxis *xaxThr;
		xaxLat = profLat->GetXaxis();
		xaxThr = profThr->GetXaxis();
		for (int i=0; i<27-k; i++) {
			Double_t bin_index_lat;
			Double_t bin_index_thr;
			bin_index_lat = xaxLat->FindBin(i);
			bin_index_thr = xaxThr->FindBin(i);
			xaxLat->SetBinLabel(bin_index_lat, byte_label[i].c_str());
			xaxThr->SetBinLabel(bin_index_thr, byte_label[i].c_str());
		}
*/
		profLat->Write();
		profThr->Write();
		outfile->Close();
	}
}
