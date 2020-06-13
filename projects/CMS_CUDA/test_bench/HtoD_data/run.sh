#/bin/bash

for i in `seq 1 10000`;
do
	echo "$i"
	./HtoD_page_a
	#./HtoD_TimeByte_1a
	#./HtoD_TimeByte_2a
	#./HtoD_TimeByte_4a
	#./HtoD_TimeByte_8a
	#./HtoD_TimeByte_16a
done
