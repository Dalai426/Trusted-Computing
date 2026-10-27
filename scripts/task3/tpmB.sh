sudo apt install openssl -y
cd ~/Desktop/Task3
sudo chmod 644 public.pem signature.sig msg
wc -c signature.sig
openssl dgst -sha256 -verify public.pem -signature signature.sig msg
printf "aletered msg" > msg
openssl dgst -sha256 -verify public.pem -signature signature.sig msg
