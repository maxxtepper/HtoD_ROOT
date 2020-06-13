#Used to compile .cu file into a share library .so file:
echo nvcc --shared -o HtoD.so HtoD_master.cu --compiler-options '-fPIC'
nvcc --shared -o HtoD.so HtoD_master.cu --compiler-options '-fPIC'

#Used to compile .C file with ROOT libs:
echo g++ -Wall -Werror `root-config --cflags` -c HtoD_test.cc -L/home/cms/CMS_CUDA/test_bench/HtoD_ROOT/HtoD.so `root-config --glibs`
g++ -Wall -Werror `root-config --cflags` -c HtoD_test.cc -L/home/cms/CMS_CUDA/test_bench/HtoD_ROOT/HtoD.so `root-config --glibs`

make
