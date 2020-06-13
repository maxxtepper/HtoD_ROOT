if [ $1 -eq 0 ]; then
	./HtoD_test gtx pinned $2
	./HtoD_test gtx paged $2
elif [ $1 -eq 1 ]; then
	./HtoD_test quadro pinned $2
	./HtoD_test quadro paged $2
else 
	echo "Usage: sh run.sh card iterations"
	echo "card: gtx=0, quadro=1"
	echo "iterations = number of runs"
fi
