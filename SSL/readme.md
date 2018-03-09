# Local Certificate Authority (PKI Server)

Shell script for generating signed certificates


### Prerequisites

Oracle JDK/jre installed and keytool command should be available in path

Install openssl with the below command 

for RHEL/Centos/Fedora
```
yum install openssl

```
for Ubuntu/debian

```
apt-get install install openssl

```
### Installing

Download GenerateCrt.sh

```
wget https://github.com/renjithrp/automation_scripts/blob/master/SSL/GenerateCrt.sh
```

Modify the settings for Certificate Authority and Signing process

```
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
```

Run the script with Fully Qualified Domain name for the server which you need certificate as input 

```
sh GenerateCrt.sh myhost.example.com
```
#Console output

```
Checking for existing CA Certificate and Key               [  OK  ]
Creating Keystore file                                     [  OK  ]
Generating CSR from Keystore file                          [  OK  ]
Signature ok
subject=/C=US/ST=Illinois/L=Lisle/O=My Organisation/OU=Testing Department/CN=myhost.example.com
Getting CA Private Key
Certificate Signing                                        [  OK  ]
Certificate was added to keystore
Importing CA Certificate to Keystore file                  [  OK  ]
Certificate reply was installed in keystore
Importing Signed Certificate to Keystore file              [  OK  ]
Certificate was added to keystore
Creating Trust Store                                       [  OK  ]
Entry for alias ca certificate myhost.example.com successfully imported.
Entry for alias myhost.example.com successfully imported.
Import command completed:  2 entries successfully imported, 0 entries failed or cancelled
Generating .P12 file                                       [  OK  ]
MAC verified OK
Generating key file form keystore                          [  OK  ]
Verifying Certificate and Key files                        [  OK  ]

```

#Certificates generated

```
#folder/file
#<HOST_NAME>/keystore.jks  - Java Key store File Containing Certificate and Key
#<HOST_NAME>/truststore.jks - Java Trust store File Containing CA Certificate
#<HOST_NAME>/<HOST_NAME>.crt - CA Signed Certificate
#<HOST_NAME>/<HOST_NAME>.crt - Key FIle for the Certificate
#<HOST_NAME>/HOST_NAME.p12 - Certificate and Key in P12 format
#<HOST_NAME>/HOST_NAME.csr - Certificate Signing Request
#<CA_FOLDER>/CA.crt - CA Certificate
#<CA_FOLDER>/CA.key - Key for CA Certificate

```
