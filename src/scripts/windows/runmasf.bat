rem Run mas with a hard-coded port number, getting data from files

cd %MAS_DIRECTORY%
cd data
echo Run "MAS Charts" to view market data charts
mas -o -b -f , 18273 *.txt
