#!/bin/bash

echo "My dc_shell script"

source ~/scripts/synopsys_setup.sh

C_DIR=$PWD
for d in *_bit*
do
	cd ${d}/syn
	echo ""
	echo ""
	echo "$PWD"
	echo 
	echo ""
	echo ""
	if [ -f "dc_synthesis.tcl" ]; then
		dc_shell-xg-t -f dc_synthesis.tcl
	fi
	cd $C_DIR
done
