#!/bin/bash

#ATENCAO O SCRIPT ABAIXO REMOVE TODOS CONTAINERS

#comando para listar a coluna NOME da saida do comando "docker ps -a", removendo a primeira linha com o 'sed'
list_con=$(docker ps -a | awk '{print $8}' | sed '1d')


for i in $list_con; do
	echo "$i"
	docker rm $i

done
