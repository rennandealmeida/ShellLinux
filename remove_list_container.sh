#!/bin/bash

#ATENCAO!!!
#O SCRIPT ABAIXO REMOVE TODOS 'CONTAINERS'(imagens nao serao afetadas) QUE NAO ESTAO EM EXECUCAO

#--------------------------------------------------------------------
#O script lista a coluna 'NAMES' na saida do comando "docker ps -a", removendo a primeira linha com o 'sed'
#ha uma possibilidade da coluna de Nomes do comando 'docker ps -a' variar a posicao de terminal para terminal ou versoes do docker-ce.
#Caso o script nao consiga encontrar essa coluna 'NAMES' altere o valor de 'awk {print $"XXXX"}', para o adequado.
#Ex:
# awk '{print $12}'  -> caso a coluna se encontre na posicao 12
# awk '{print $8}'   -> caso a coluna se encontre na posicao 8
# awk '{print $10}'  -> caso a coluna se encontre na posicao 10

#Abaixo um exemplo dos campos
#CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
#4238b5a4cc37        debian              "bash"              44 minutes ago      Up 44 minutes                           affectionate_taussig
#5398de77f440        debian              "bash"              44 minutes ago      Up 44 minutes                           blissful_tharp

#--------------------------------------------------------------------
#list_con=$(docker ps -a | awk '{print $12}' | sed '1d')
list_con=$(docker ps -a | cut -c170-200 | sed '1d')


for i in $list_con; do
	echo "$i"
	docker rm $i

done
