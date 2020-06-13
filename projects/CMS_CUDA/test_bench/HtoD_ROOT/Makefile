CC=g++
CFLAGS=-c -fPIC `root-config --cflags`
LDFLAGS=`root-config --libs`
SOURCES0= HtoD_test.cc
SOURCES1= profile_HtoD.cc
SOURCES2= histogram_HtoD.cc
OBJECTS0=$(SOURCES0:.cc=.o)
OBJECTS1=$(SOURCES1:.cc=.o)
OBJECTS2=$(SOURCES2:.cc=.o)
LIBRARIES0= /home/cms/CMS_CUDA/test_bench/HtoD_ROOT/HtoD.so
LIBRAREIS1=
LIBRAREIS2=
EXECUTABLE0=HtoD_test
EXECUTABLE1=profile_HtoD
EXECUTABLE2=histogram_HtoD

all: $(SOURCES0) $(SOURCES1) $(SOURCES2) $(EXECUTABLE0) $(EXECUTABLE1) $(EXECUTABLE2)

	
$(EXECUTABLE0): $(OBJECTS0)
	$(CC) $(OBJECTS0) -o $@ $(LIBRARIES0) $(LDFLAGS) 

$(EXECUTABLE1): $(OBJECTS1)
	$(CC) $(OBJECTS1) -o $@ $(LIBRARIES1) $(LDFLAGS) 

$(EXECUTABLE2): $(OBJECTS2)
	$(CC) $(OBJECTS2) -o $@ $(LIBRARIES2) $(LDFLAGS) 

.cc.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm ./*~ ./*.o ./HtoD_test ./profile_HtoD ./histogram_HtoD
