#!/bin/bash

list_con="container1 container2 container3"


for i in $list_con; do
	echo "$i"
	docker rm $i

done
