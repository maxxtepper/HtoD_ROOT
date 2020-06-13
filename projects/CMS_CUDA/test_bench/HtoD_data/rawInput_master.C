#include <iostream>
#include <fstream>
#include <cassert>
#include <TFile.h>
#include <TTree.h>
#include <TMath.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <sstream>

void rawInput_master(int argc, char *argv[]) {
	std::string outfileName, infileName;
	std::string outF, inF;
	std::string outPref, inPref;
	std::string bytes, line;

	std::string label;
	label = argv[1];

	std::string aList[5] = {"1a_", "2a_", "4a_", "8a_", "16a_"};

	inPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/data_files/" + label + "_data/";
	outPref = "/home/cms/CMS_CUDA/test_bench/HtoD_data/raw_root_files/" + label + "_raw/";

	for (int i=0; i<5; i++) {
		int bytesI = i;
		while (true) {
			bytes = std::to_string(bytesI);
			inF = "rawData_bytes_" + aList[i] + "_" + bytes + ".txt";
			infileName = inPref + inF;
			std::cout << infileName << std::endl;
			ifstream fin;
			fin.open(infileName.c_str());
			if (!fin.fail()) {
				outF = "rawData_bytes_" + aList[i] + "_" + bytes + ".root";
				outfileName = outPref + outF;

				TFile *outfile;
				outfile = TFile::Open(outfileName.c_str(), "RECREATE");

				Float_t time = 0;
				Float_t bytesF = 0;
				Float_t rate = 0;
				
				TTree *rawBT = new TTree("rawByteTimes", "The Time vs. Bytes Raw Data");
				rawBT->Branch("time", &time, "time/F");
				rawBT->Branch("bytesF", &bytesF, "bytesF/F");
				rawBT->Branch("rate", &rate, "rate/F");
		
				std::cout << "Extracting from " << infileName << ".....\n";
				while (true){
					std::getline(fin, line);
					if (fin.eof()) break;
					istringstream strm(line);
					std::string buf;
					std::getline(strm, buf, ',');
					time = stof(buf.c_str());
					std::getline(strm, buf);
					bytesF = stof(buf.c_str());
					bytesF = TMath::Power(2,bytesF)*sizeof(float)*8;
					rate = (bytesF/8)*1e-6/(time);
//					rate = (((TMath::Power(2,bytesF))*sizeof(float))*1e-6)/(time);
					rawBT->Fill();
				}
				fin.close();
				rawBT->Write();
				outfile->Close();
			} else {
				std::cout << "Something is wrong...\n";
				break;
			}
			bytesI++;
		}
	}
}	
