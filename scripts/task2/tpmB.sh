sudo apt install openssl -y
cd ~/Desktop/Task1
wc -c signature.sig
openssl dgst -sha256 -verify public.pem -signature signature.sig msg
printf "aletered msg" > msg
openssl dgst -sha256 -verify public.pem -signature signature.sig msg
