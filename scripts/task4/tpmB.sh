cd ~/Desktop/Task4
sudo chmod 644 public.pem signature.sig msg
openssl dgst -sha256 -verify public.pem -signature signature.sig msg