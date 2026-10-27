**the environment**
Reproducing the experiments requires two Ubuntu machines with a TPM and tpm2-tools. Two machines must be able to reach each other over the internet and have SSH enabled to transfer keys, messages, and signatures.
**how to start TPM-A**
```bash
ls /sys/class/tpm/
sudo apt update && sudo apt install -y tpm2-tools
```
**how to start TPM-B**
```bash
ls /sys/class/tpm/
sudo apt update && sudo apt install -y tpm2-tools
```
**how to run the RSA experiment**
In the machine A,
```bash
cd ./scripts/task2
chmod +x tpmA.sh
./tpmA.sh $IP $Username
```
The IP address and username of Machine B must be specified in the signing command.

In the machine B,
```bash
cd ./scripts/task2
chmod +x tpmB.sh
./tpmB.sh
```
**how to run the ECC experiment**
In the machine A,
```bash
cd ./scripts/task3
chmod +x tpmA.sh
./tpmA.sh $IP $Username
```
The IP address and username of Machine B must be specified in the signing command.

In the machine B,
```bash
cd ./scripts/task3
chmod +x tpmB.sh
./tpmB.sh
```
**how to run the PCR-bound signing experiment**
In the machine A,
```bash
cd ./scripts/task4
chmod +x tpmA.sh creatingKeysWithAuthorization.sh
./creatingKeysWithAuthorization.sh --match true
./tpmA.sh $IP $Username
```
The creatingKeysWithAuthorization script uses the --match flag to configure whether the PCR value matches its expected value.
The IP address and username of Machine B must be specified in the tpmA script.

In the machine B,
```bash
cd ./scripts/task4
chmod +x tpmB.sh
./tpmB.sh
```

