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
#include <TH1F.h>
#include <TGraph.h>
#include <TAxis.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <sstream>

#define BYTE_MAX 28

const uint32_t BYTES[BYTE_MAX] = {1<<0, 1<<1, 1<<2, 1<<3, 1<<4, 1<<5, 1<<6, 1<<7, 1<<8, 1<<9, 1<<10, 1<<11, 1<<12, 1<<13, 1<<14, 1<<15, 1<<16, 1<<17, 1<<18, 1<<19, 1<<20, 1<<21, 1<<22, 1<<23, 1<<24, 1<<25, 1<<26, 1<<27};

int main(int argc, char *argv[]) {
	if (argc != 3) {
		printf("Usage: ./histogram_HtoD card memory\n\
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

	std::string byte_label[BYTE_MAX] = {"4","8","16","32","64","128","256","512",
		"1K","2K","4K","8K","16K","32K","64K","128K", "256K","512K","1M","2M",
		"4M","8M","16M","32M","64M","128M","256M","512M"};

	std::string infileName, outfileName;
	std::string inF, outF;
	std::string inPref, outPref;
	std::string byte;

	inPref = pwd + "/raw_root/";
	outPref = pwd + "/histogram_root/";
	outF = "histogram_" + card + "_HtoD_" + memory + ".root";
	outfileName = outPref + outF;

	TFile *outfile;
	outfile = TFile::Open(outfileName.c_str(), "RECREATE");

	Double_t x_mean[BYTE_MAX] = {0};
	Double_t time_mean[BYTE_MAX] = {0};
	Double_t rate_mean[BYTE_MAX] = {0};

	//	Open a single .root file to make a histogram
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
			//std::cout << "Adding file " << inF << std::endl;
			chain->Add(infileName.c_str());
		} else break;

		Float_t time = 0;
		Float_t rate = 0;

		chain->SetBranchAddress("time", &time);
		chain->SetBranchAddress("rate", &rate);	

		std::string hGLat_id = "histoLatency_" + memory + "_" + byte_label[i] + "B";
		std::string hGLat_name = "Host to Device Latency - " + byte_label[i] + "Bs";

		Float_t time_bin, time_max, time_min;
		time_max = chain->GetMaximum("time");
		time_min = chain->GetMinimum("time");
		time_bin = 200;

		TH1F *histo = new TH1F(hGLat_id.c_str(), hGLat_name.c_str(), time_bin, time_min, time_max);

		Int_t nentries = chain->GetEntries();

		for (Int_t j=0; j<nentries; j++) {
			chain->GetEntry(j);
			histo->Fill(time);
		}
	
		x_mean[i]    = TMath::Power(2,i)*sizeof(float)*8;
		time_mean[i] = histo->GetMean(1);
		rate_mean[i] = (x_mean[i]*1e-6)/(time_mean[i]);

		histo->SetLineWidth(2);
		histo->GetXaxis()->SetTitle("Time (milliseconds)");
		histo->GetYaxis()->SetTitle("Events");

		std::cout << "Writing file " << outF << std::endl;
		histo->Write();
	}
	std::string graph_title0;
	std::string graph_title1;
	
	graph_title0 = "Host to Device Latency (Time vs. Bits)";
	TGraph *graph0 = new TGraph(BYTE_MAX, x_mean, time_mean);
	graph0->SetLineColor(4);
	graph0->SetLineWidth(3);
	graph0->SetMarkerColor(4);
	graph0->SetMarkerStyle(21);
	graph0->SetTitle(graph_title0.c_str());
	graph0->GetXaxis()->SetTitle("Bits");
	graph0->GetYaxis()->SetTitle("Time (milliseconds)");
	
	graph_title1 = "CPU to GPU Throughput";
	TGraph *graph1 = new TGraph(BYTE_MAX, x_mean, rate_mean);
	graph1->SetLineColor(4);
	graph1->SetLineWidth(3);
	graph1->SetMarkerColor(4);
	graph1->SetMarkerStyle(21);
	graph1->SetTitle(graph_title1.c_str());
	graph1->GetXaxis()->SetTitle("Bits");
	graph1->GetYaxis()->SetTitle("Rate (GB/s)");

	graph0->Write();
	graph1->Write();

	outfile->Close();

	return 0;
}

