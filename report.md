### System setup
As two TPM-enabled environments are required to accomplish tasks, I created 2 linux virtual machines called Machine and Machine2 with virtual TPMs. Both machines have tpm2-tools installed, which is used to communicate with the TPM.
### TPM-A and TPM-B architecture
Regarding integration with device hardware, the TPMs used in my virtual machines are virtual TPMs, since they are not physically integrated with my computer (host machine) hardware. A virtual TPM is a software-emulated device managed by a host machine, and it imitates the functionalities of a physical TPM.

Regarding the internal architecture of TPM, TPMs consist of internal components, including a secure cryptographic engine, non-volatile and volatile memory, and control subsystems. The platform configuration registers (PCRs) and command processing engine are included in the control systems, and they manage system state and policy enforcement. While non-volatile storage includes the Endorsement Key (EK), a unique, factory-installed identity key, and the Storage Root Key (SRK), volatile memory contains temporary keys, sessions, and buffers.
### Task 2 : Explanation of the RSA signing and verification workflow
RSA key generation workflow consists of the steps below:

1. The command used for creating a parent key : sudo tpm2_createprimary -C o -c primary.ctx
First, primary object, which serves as the parent key of its children keys, should be created, before the private and public key belong to it being created. The -C o option chooses the owner hierarchy for storing my keys securely.
2. The command used for creating keys under a parent key : sudo tpm2_create -G rsa -u rsa.pub -r rsa.priv -C primary.ctx
The command generates public and private key blobs which are stored on a machine filesystem.
3. The command used for loading blob keys into TPM using its parent key : sudo tpm2_load -C primary.ctx -u rsa.pub -r rsa.priv -c rsa.ctx
Protected keys (blobs) should be loaded so that they can be used. The command writes context information of loaded keys into rsa.ctx file, allowing the keys to be used for other TPM commands.
4. Command used for signing a message using the reference of keys : sudo tpm2_sign -c rsa.ctx -g sha256 -s rsassa -f plain -o signature.sig msg
5. Command used for transforming a child public key blob to a simple public key : sudo tpm2_readpublic -c rsa.ctx -f pem -o public.pem
6. openssl dgst -sha256 -verify public.pem -signature signature.sig msg
Afterwards, the signature and its message is verified by the public key.

Regarding key storage, the TPM defines four main hierarchies: the owner hierarchy for managing general-purpose keys, the endorsement hierarchy for supporting attestation and identity functions, the platform hierarchy for firmware-related trust operations, and the null hierarchy for creating temporary keys. Each hierarchy has its own seed, parent keys, child keys, and authorization rules. The seed is an inalterable value that serves as the TPM’s true root key. The parent keys are deterministically (the same seed and parameters always derive the same key) derived from the hierarchy seed and the primary object's parameters. Parent keys are stored persistently in TPM non-volatile memory and used to encrypt(decrypt) child keys.
### Task 3 : Explanation of the ECC signing and verification workflow
Elliptic Curve Cryptography (ECC) is a cryptographic key pair designed to encrypt a message and verify a signature derived from the message.
RSA public and private keys are generated based on large prime numbers, while ECC keys are created based on the mathematical theory of elliptic curves. Whereas RSA-2048 requires 2048-bit prime numbers to generate keys, an ECC-256 key pair with comparable security to RSA-2048 requires a 256-bit secret number.  After generating RSA and ECC keys using the TPM, I compared their blob sizes and parent keys. While the RSA public and private key blobs were 280 bytes and 224 bytes, respectively, the ECC private key blob size was 128 bytes and the public key blob was 88 bytes. However, the parent keys of both algorithms in the TPM were the same: 1602 bytes.

The main advantages of ECC compared with RSA are:
- Requires less storage than the RSA
- The same level of security as the RSA
- Uses less computational resource than RSA
- When keys are transmitted over a network, the ECC keys require lower network bandwidth

Command used for creating ECC keys: sudo tpm2_create -G ecc -u ecc.pub -r ecc.priv -C primaryecc.ctx
A specific algorithm used for generating keys is referred to as the -G option.
Command used for signing a message using the ECC key: sudo tpm2_sign -c ecc.ctx -g sha256 -s ecdsa -f plain -o signature.sig msg
Elliptic Curve Digital Signature Algorithm, the digital signature algorithm for ECC, is specified with the -s option.

### Task 4 : Explanation of the PCR-bound key mechanism
One of TPM's services is authorization. Using several authorization policies, the TPM executes specific actions and allows access to its protected resources only when certain conditions are satisfied. The PCR-bound key mechanism is an authorization mechanism defined by a policy that allows users to use keys when the state of system components satisfies a certain condition, and a specific PCR register's value becomes equal to its expected value. PCRs are memory slots in TPM, records the hashed value of system components called the measurement, and can represent certain state of system components. Consequently, any manipulation in these components alters the PCR values, allowing the TPM to detect unauthorized changes and securely deny access to its protected resources.

**What TPM-B can and cannot conclude**
The signature, message, and public key acquired by the TPM-B can prove only that the message has not been modified, but they cannot prove they originate from the TPM-A. If the TPM-A authenticates its identity to the TPM-B using a Trusted Authority, the signature and public key can assert that the signature comes from the genuine and trustworthy TPM-A. Without a secure attestation mechanism, the TPM-B cannot assume the state of TPM-A or its components are expected or the TPM-A is not compromised, because attackers can perform Man-in-the-Middle attacks or sends a tampered signature to the TPM-B from the compromised TPM-A.