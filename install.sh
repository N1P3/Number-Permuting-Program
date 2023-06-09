#!/bin/bash

location=$(pwd)

bug_check(){
#gdzie: $1 to komunikat wypisywany dla uzytkownika, $2 to error exit code, a $3 to flaga, ktora podpowiada w ktory if nalezy wejsc.
#mowiac bardziej szczegolowo: flaga $3 determinuje czy blad byl krytyczny i czy blad ten dotyczyl czesci zwiazanej 
#z instalacja programu perm czy czesci zwiazanej z instalacja programu do sluzacego do testowania/przeprowadzania testow automatycznych.

	if (($? != 0 && $3 == 1))
	then 
		echo $1
		echo "badz program jest juz zainstalowany w tym (obecnym) folderze ($location)."
		echo 'Przerywam dzialanie instalatora.'
		exit $2
	fi
	if (($? != 0 && $3 == 2))
	then 
		echo $1
		echo "badz program do testowania jest juz zainstalowany w tym (obecnym) folderze ($location)."
		echo 'Przerywam dzialanie instalatora.'
		exit $2
	fi
	if (($? != 0))
	then
		echo $1
		echo 'Przerywam dzialanie instalatora.'
		exit $2
	fi

}

mkdir build
bug_check 'Nie udalo sie utworzyc folderu build,' 22 1

chmod u+rwx -R build
bug_check 'Nie udalo sie zmienic uprawnien dla Folderu build,' 23 1

cd build/

cmake ..
bug_check 'Blad programu cmake. Przerywam dzialanie instalatora.' 31 0

make
bug_check 'Blad programu make podczas kompilacji perm. Przerywam dzialanie instalatora.' 32 0

cd ..
chmod u+rwx -R build
bug_check 'Nie udalo sie zmienic uprawnien dla Folderu build.' 23 0

mkdir bin

mv build/generator.out build/input_checker.out build/perm_processing.out build/rdg.out bin/


echo 'Czy zainstalowac rowniez pakiet do testowania? [y/n]:'
read input
if [ $input = "y" ]
then
	echo 'instaluje pakiet do testowania...'
	mkdir test
	bug_check 'Nie udalo sie utworzyc folderu test/,' 41 2

	gcc src/input_checker2.c -o bin/input_checker2.out
	bug_check 'Nie udalo sie skompilowac podprogramu input_checker2.out - blad gcc,' 42 2

	cp ./src/testing.sh ./test/
	bug_check 'Nie udalo sie skopiowac programu testing.sh z folderu src/ do folderu test/,' 43 2
	
	mv src/parameters.txt test/
	bug_check 'Nie udalo sie przeniesc pliku parameters.txt z folderu src/ do folderu test/,' 48 0
	
	cp ./src/instructions_for_gnuplot.p ./test/
	bug_check 'Nie udalo sie skopiowac programu testing.sh z folderu src/ do folderu test/,' 43 2 
fi
