#!/bin/bash

echo "My dc_shell script"

C_DIR=$PWD
for d in *_bit*
do
	cd ${d}/syn
	for f in 500MHz 1GHz 
	do
		cd $f
		echo ""
		echo ""
		echo "$PWD"
		echo 
		echo ""
		echo ""
		if [ -f "run.scr" ]; then
			rm -rf reports
			mkdir reports
			dc_shell-xg-t -f run.scr
		fi
		cd ..
	done
	cd $C_DIR
done
