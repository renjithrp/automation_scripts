#!/bin/bash
#@Auther: Renjith
#@Shell Script for generating signed certificate like a local PKI Server
#Usage: GenerateCrt.sh <HOST_NAME>
#Output 
#folder/file
#<HOST_NAME>/keystore.jks  - Java Key store File Containing Certificate and Key
#<HOST_NAME>/truststore.jks - Java Trust store File Containing CA Certificate
#<HOST_NAME>/<HOST_NAME>.crt - CA Signed Certificate
#<HOST_NAME>/<HOST_NAME>.crt - Key FIle for the Certificate
#<HOST_NAME>/HOST_NAME.p12 - Certificate and Key in P12 format
#<HOST_NAME>/HOST_NAME.csr - Certificate Signing Request
#<CA_FOLDER>/CA.crt - CA Certificate
#<CA_FOLDER>/CA.key - Key for CA Certificate

#Settings for Certificate Authority (CA)
CA_FOLDER='CA'
CA_PASSWORD='changeit'
CA_CN='CertificateAuthority.com'
CA_ORG='My Organization'
CA_OU='IT Department'
CA_LOCALITY='Lisle'
CA_STATE='Illinois'
CA_COUNTRY='US'
CA_VALIDITY='1024'
CA_KEYSIZE='4096'

#Settings for Certificate Signing
CSR_ORG='My Organisation'
CSR_OU='Testing Department'
CSR_LOCALITY='Lisle'
CSR_STATE='Illinois'
CSR_COUNTRY='US'
KEYSTORE_PASSWORD='changeit'
CRT_VALIDITY='365'
CRT_KEYSIZE='4096'

#Advanced Settings
CRT_SIG_ALG='SHA256withRSA'
CRT_KEY_ALG='RSA'

HOST_NAME=$1
. /etc/rc.d/init.d/functions

usage(){

	echo ""
	echo "Usage ${0} <FQDN>"
	echo "Output:-"
	echo "folder/file"
	echo "<HOST_NAME>/keystore.jks  - Java Key store File Containing Certificate and Key"
	echo "<HOST_NAME>/truststore.jks - Java Trust store File Containing CA Certificate"
	echo "<HOST_NAME>/<HOST_NAME>.crt - CA Signed Certificate"
	echo "<HOST_NAME>/<HOST_NAME>.crt - Key FIle for the Certificate"
	echo "<HOST_NAME>/HOST_NAME.p12 - Certificate and Key in P12 format"
	echo "<HOST_NAME>/HOST_NAME.csr - Certificate Signing Request"
	echo "<CA_FOLDER>/CA.crt - CA Certificate"
	echo "<CA_FOLDER>/CA.key - Key for CA Certificate"
	exit 1

}

console_msg(){

        if [ $1 -ne 0 ];then

                echo  -n "$2"
                echo_failure
                echo ""

        else
                echo -n "$2"
                echo_success
                echo ""
        fi
}

createCA(){

        mkdir $CA_FOLDER 2>>/dev/null
        openssl genrsa -des3 -out $CA_FOLDER/CA.key -passout pass:$CA_PASSWORD $CA_KEYSIZE -sha256 -extensions v3_ca
        openssl req -x509 -new -nodes -key $CA_FOLDER/CA.key -passin pass:$CA_PASSWORD -days $CA_VALIDITY -out $CA_FOLDER/CA.crt -sha256 -extensions v3_ca -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCALITY/O=$CA_ORG/OU=$CA_OU/CN=$CA_CN"
        console_msg "$?" "Creating CA Certificate for $CA_CN"

}

checkCRT(){

        if [ -f $1 ] || [ -f $2 ]];then

                SHA_KEY=$(openssl pkey -in $1 -passin pass:changeit -pubout -outform pem | sha256sum | awk '{print $1}')
                SHA_CRT=$(openssl x509 -in $2 -pubkey -noout -outform pem | sha256sum | awk '{print $1}')
                if [[ $SHA_KEY == $SHA_CRT ]];then
                        console_msg "0" "$3"
                else
                        console_msg "2" "$3"
                        exit 2
                fi

        else
                return 1
        fi
}

genCRT(){

        mkdir $HOST_NAME 2>>/dev/null
        keytool -genkey -alias $HOST_NAME -keyalg $CRT_KEY_ALG -keystore $HOST_NAME/keystore.jks -keysize $CRT_KEYSIZE -sigalg $CRT_SIG_ALG -dname "CN=$HOST_NAME, OU=$CSR_OU, O=$CSR_ORG, L=$CSR_LOCALITY, S=$CSR_STATE, C=$CSR_COUNTRY" -storepass $KEYSTORE_PASSWORD -keypass $KEYSTORE_PASSWORD
        console_msg "$?" "Creating Keystore file"

        keytool -certreq -alias $HOST_NAME -keystore $HOST_NAME/keystore.jks -file $HOST_NAME/$HOST_NAME.csr -storepass $KEYSTORE_PASSWORD
        console_msg "$?" "Generating CSR from Keystore file"

        openssl x509 -req -in $HOST_NAME/$HOST_NAME.csr -CA $CA_FOLDER/CA.crt -CAkey $CA_FOLDER/CA.key -passin pass:$CA_PASSWORD -CAcreateserial -out $HOST_NAME/$HOST_NAME.crt -days $CRT_VALIDITY -sha256
        console_msg "$?" "Certificate Signing"

        keytool -import -trustcacerts -alias "CA Certificate $HOST_NAME" -file $CA_FOLDER/CA.crt -keystore $HOST_NAME/keystore.jks -storepass $KEYSTORE_PASSWORD -noprompt
        console_msg "$?" "Importing CA Certificate to Keystore file"

        keytool -import -trustcacerts -alias $HOST_NAME -file $HOST_NAME/$HOST_NAME.crt -keystore $HOST_NAME/keystore.jks -storepass $KEYSTORE_PASSWORD -noprompt
        console_msg "$?" "Importing Signed Certificate to Keystore file"

        keytool -import -trustcacerts -alias "CA Certificate $HOST_NAME" -file $CA_FOLDER/CA.crt -keystore $HOST_NAME/truststore.jks -storepass $KEYSTORE_PASSWORD -noprompt
        console_msg "$?" "Creating Trust Store"

        keytool -importkeystore -srckeystore $HOST_NAME/keystore.jks -destkeystore $HOST_NAME/$HOST_NAME.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSWORD  -deststorepass $KEYSTORE_PASSWORD
        console_msg "$?" "Generating .P12 file"

        openssl pkcs12 -in $HOST_NAME/$HOST_NAME.p12 -out $HOST_NAME/$HOST_NAME.key -nocerts -nodes  -passin pass:$KEYSTORE_PASSWORD
        console_msg "$?" "Generating key file form keystore"

	checkCRT $HOST_NAME/$HOST_NAME.key $HOST_NAME/$HOST_NAME.crt "Verifying Certificate and Key files"
		
}

if [[ -z $HOST_NAME ]];then

	usage
	
fi

checkCRT $CA_FOLDER/CA.key $CA_FOLDER/CA.crt "Checking for existing CA Certificate and Key"

if [[ $? -eq 1 ]];then
	createCA 
fi 

genCRT

