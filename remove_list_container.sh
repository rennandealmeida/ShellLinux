#!/bin/bash

#ATENCAO!!!
#O SCRIPT ABAIXO REMOVE TODOS 'CONTAINERS'(imagens nao serao afetadas) QUE NAO ESTAO EM EXECUCAO

#--------------------------------------------------------------------
#O script lista a coluna 'CONTAINER ID' na saida do comando "docker ps -a", removendo a primeira linha com o 'sed' e filtrando apenas container que estao com status 'exited'

#Abaixo um exemplo dos campos
#CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
#4238b5a4cc37        debian              "bash"              44 minutes ago      Up 44 minutes                           affectionate_taussig
#5398de77f440        debian              "bash"              44 minutes ago      Up 44 minutes                           blissful_tharp

#--------------------------------------------------------------------

RED='\033[0;31m' 

list_con=$(docker ps -a --filter "exited=0" | awk '{print $1}' | sed '1d')

if [ -z $list_con ]
then
	echo ""
	echo -e "${RED}Nao existem containers em modo exited..\n"

else
	for i in $list_con; do
                docker inspect $i | grep Name | head -n 1
                docker rm $i
                echo "removido"
        done
fi
