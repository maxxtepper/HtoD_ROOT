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

void histoTimeByte_all() {
	std::string infileName, outfileName;
	std::string inF, outF;
	std::string inPref, outPref;
	std::string byte;

	std::string aList[5] = {"1a", "2a", "4a", "8a", "16a"};

	inPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/raw_root_files/";
	outPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/histogram_root_files/";

	std::string byte_label[27] = {"4","8","16","32","64","128","256","512",
		"1K","2K","4K","8K","16K","32K","64K","128K", "256K","512K","1M","2M",
		"4M","8M","16M","32M","64M","128M","256M"};

	//	TCanvas *c0 = new TCanvas("c0", "All hprof0", 1);
	//	TCanvas *c1 = new TCanvas("c1", "All hprof1", 1);

	for (int k=0; k<1; k++) {
		outF = "histogram_bytes_" + aList[k] + ".root";
		outfileName = outPref + outF;
		TFile *outfile;
		outfile = TFile::Open(outfileName.c_str(), "RECREATE");

		Double_t x_mean[27] = {0};
		Double_t time_mean[27] = {0};
		Double_t rate_mean[27] = {0};

		//	Open a single .root file to make a histogram
		for (int i=0; i<27; i++) {
			TChain *chain = new TChain("rawByteTimes");
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

			Float_t time = 0;
			Float_t bytesF = 0;
			Float_t rate = 0;

			chain->SetBranchAddress("time", &time);
			chain->SetBranchAddress("bytesF", &bytesF);
			chain->SetBranchAddress("rate", &rate);	
			std::string histo_name, histo_title;
			histo_name = "cpugpuLatency_" + byte_label[i];
			histo_title = "CPU to GPU Latency for " + byte_label[i] + "B Transfer";

			Double_t time_bin, time_max, time_min;
			time_max = chain->GetMaximum("time");
			time_min = chain->GetMinimum("time");
			time_bin = 500;

			TH1F *histo = new TH1F(histo_name.c_str(), histo_title.c_str(), time_bin, time_min, time_max);

			Int_t nentries = chain->GetEntries();

			for (Int_t j=0; j<nentries; j++) {
				chain->GetEntry(j);
				histo->Fill(time);
			}
			time_mean[i] = histo->GetMean(1);

			x_mean[i] = bytesF;
			rate_mean[i] = (bytesF/8)*1e-6/(time_mean[i]);
//			rate_mean[i] = ((TMath::Power(2, i))*sizeof(float)*1e-6)/(time_mean[i]);

			histo->SetLineWidth(2);
			histo->GetXaxis()->SetTitle("Time (milliseconds)");
			histo->GetYaxis()->SetTitle("Events");

			std::cout << "Writing file " << outF << std::endl;
			histo->Write();
		}
		std::string graph_title0;
		std::string graph_title1;
		
		graph_title0 = "CPU to GPU Latency";
		TGraph *graph0 = new TGraph(27, x_mean, time_mean);
		graph0->SetLineColor(4);
		graph0->SetLineWidth(2);
		graph0->SetMarkerColor(4);
		graph0->SetMarkerStyle(21);
		graph0->SetTitle(graph_title0.c_str());
		graph0->GetXaxis()->SetTitle("Bits");
		graph0->GetYaxis()->SetTitle("Time (milliseconds)");
		
		graph_title1 = "CPU to GPU Throughput";
		TGraph *graph1 = new TGraph(27, x_mean, rate_mean);
		graph1->SetLineColor(4);
		graph1->SetLineWidth(2);
		graph1->SetMarkerColor(4);
		graph1->SetMarkerStyle(21);
		graph1->SetTitle(graph_title1.c_str());
		graph1->GetXaxis()->SetTitle("Bits");
		graph1->GetYaxis()->SetTitle("Rate (GB/s)");
/*
		TAxis *xax0;
		xax0 = graph0->GetXaxis();
		for (int i=0; i<27; i++) {
			Double_t bin_index;
			bin_index = xax0->FindBin(i);
			xax0->SetBinLabel(bin_index, byte_label[i].c_str());
		}
		TAxis *xax1;
		xax1 = graph1->GetXaxis();
		for (int i=0; i<27; i++) {
			Double_t bin_index;
			bin_index = xax0->FindBin(i);
			xax1->SetBinLabel(bin_index, byte_label[i].c_str());
		}
*/
		graph0->Write();
		graph1->Write();

		outfile->Close();
	}
}
