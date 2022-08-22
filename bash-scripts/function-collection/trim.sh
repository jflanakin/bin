#!/bin/bash

__trim(){
	value="$1"
	echo $value | sed 's:/*$::'
}