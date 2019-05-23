#!/bin/bash

#Script Desenvolvido para uma atividade especifica, nao funcionara de uma maneira universal,
#No entanto pode auxiliar em alguma pesquisa ou duvida que esteja passando.

#Modo de funcionamento:
#Passe 2 argumentos no momento de execucao do script (ex script.sh $nome_chave_cliente $ip_cliente_vpn)
#entao : script.sh fulano 192.168.0.2

#OBS: Na etapa de criar a chave criptografada eh necessario baixar a ferramenta CRYPT TOOL (python)

CLIENT=$1
IP=$2
EASY_RSA_PATH=/etc/openvpn/easy-rsa
VPN_PATH=/opt/empresa/vpn
KEY_PATH=/opt/empresa/vpn/key
VPN_IP=/etc/openvpn/ipp.txt
CRYPT_TOOL=/opt/empresa/vpn/crypt_tool/crypto
OLD_CLIENT=$(cat /etc/openvpn/ipp.txt | grep $IP | cut -d "," -f1) #busca nome do cliente atrelado ao ip passado como argumento
VERIFICA_IP=$(find /etc/openvpn/ipp.txt -exec grep -l $IP {} \;) #verifica se o ip passado como argumento encontra-se no arquivo ipp.txt

newclient(){

#          Gerando a customizacao client.ovpn
	{
           cat /opt/empresa/vpn/ovpn/client-common
	   echo "<ca>"
	   cat /etc/openvpn/easy-rsa/pki/ca.crt
	   echo "</ca>"
	   echo "<cert>"
	   cat /etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt
	   echo "</cert>"
	   echo "<key>"
           cat /etc/openvpn/easy-rsa/pki/private/$CLIENT.key
	   echo "</key>"
	   echo "<tls-auth>"
	   cat /etc/openvpn/ta.key
	   echo "</tls-auth>" 
        } >> ${KEY_PATH}/$CLIENT.ovpn
	
	$CRYPT_TOOL $KEY_PATH/$CLIENT.ovpn

	echo "$CLIENT,$IP" >> $VPN_IP 

}
createclient(){

#       Se o ip nao existir no arquivo /etc/openvpn/ipp.txt, eh criado uma nova chave e atrelada ao nome do cliente que foi passado como argumento
	cd $EASY_RSA_PATH
	./easyrsa build-client-full $CLIENT nopass &> /dev/null
#       Gerando o cliente.ovpn customizado
	newclient "$CLIENT"
	mv $EASY_RSA_PATH/$CLIENT.empresa /$KEY_PATH
	echo ${KEY_PATH}/${CLIENT}.empresa
}

revokeclient(){

#	Caso a chave ja exista, sera revogada substituindo o antigo cliente pelo novo
#	Obs: O antigo cliente esta atrelado ao ip passado como argumento. 
	cd /etc/openvpn/easy-rsa/
	./easyrsa --batch revoke $OLD_CLIENT &> /dev/null
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl &> /dev/null
	rm -rf pki/reqs/$OLD_CLIENT.req
	rm -rf pki/private/$OLD_CLIENT.key
	rm -rf pki/issued/$OLD_CLIENT.crt
	rm -rf /etc/openvpn/crl.pem
        sed -i "/^${OLD_CLIENT},/d" $VPN_IP

	cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
	
	# CRL is read with each client connection, when OpenVPN is dropped to nobody
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem

	createclient

}

main(){

#Verifica se o IP inserido como argumento consta no arquivo ipp.txt | se constar, revoga a chave | se nao constar, cria chave.
if [ -z $VERIFICA_IP ]
then
	createclient
else
	revokeclient
fi
}

main
