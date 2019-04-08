#!/bin/bash

#ATENCAO O SCRIPT ABAIXO APAGA "TODAS" IMAGENS DOC

#comando para listar a coluna images ID do comando 'docker images', removendo a primeira linha
list_con=$(docker images | awk '{print $3}' | sed '1d')


for i in $list_con; do
	echo "$i"
	docker rmi $i

done
