# Features

Weavechain is a complex infrastructure layer that can be configured to act differently for each data and compute sharing agreement, depending on the needs of the specific use case. The complexity is hidden with a simple normalized API that allows access to data stored on different types of databases or file storages and provides an easy way to enable sharing, confidential compute or monetization on top of that data. One or many of the features below can be enabled for each private network. The nodes can perform data and compute tasks on their own or private dApps can be built on top of them.

- Private or Public Data Storage
	+ Databases and File Storages
- Role Based Access Control
- Dynamic Row Level Access Rights
- Full Audit, including for reads
- Data Replication
	+ Non-Replicated private collections or Replicated to a Trust Network
	+ Storage and Integrity Proofs
	+ Scheduled Integrity Checks or Random Sampling
- Data Recovery
- Self-Sovereign Data Sharing
- Polling or streaming connections
- Custom Encryption In Transit that can be enabled on top of or when SSL/TLS is not available
- Custom Encryption At Rest
- Personal Identifiable Information and Time Series Obfuscation
- Data Brokerage
	+ Caching
	+ Proxy Re-Encryption
- Data Streaming
- Data Monetization
	+ pre-paid gating using NFTs, marketplace smart contracts or direct payment subscriptions
	+ custodial wallet dynamic payments based on usage
	+ custodial wallets transfers with periodic bridging on-chain
	+ live data access, datasets snaphots or rolling datasets
- Multiple blockchains supported for authentication, integrity proofs or monetization
- Multiple Web3 and Web2 Authentication methods
- Compute Monetization
- Integrity Proofs
	+ off-chain and on-chain (private or public blockchains)
	+ Integrity Signatures from source
	+ Threshold Signatures 
	+ Time Series Immutability Proofs, records batching
	+ Merkle Trees and signed root hashes
	+ Snapshot or Live Merkle Trees
	+ Table Update Zero-Knowledge Proof
- Confidential Compute
	+ Compute To Data
		* Docker
		* WebAssembly
		* in-process node plugins
	+ Multi-Party Computing (SPDZ, using FRESCO from Alexandra Instituttet)
	+ Homomorphic Encryption (CKKS, using SEAL/EVA from Microsoft)
	+ Federated and Split Learning
	+ Zero-Knowldege Proofs for Data (Bulletproofs)
- Secure Enclaves support (SGX)
- Data Lineage, Row Level Traceback
- Computational Lineage
- Verifiable Credentials issuing
- Monetization for any dockerized 3rd party service using generic API forwarding
- Integrity guarantees for any dockerized 3rd party service using API forwarding
- Wallet-to-wallet and session-to-session Messaging
- Optional Quantum Resistant Signatures and Hashing
- Oracle Middleware
- Data or Compute Marketplaces
- Private or Public node access
- Node API limiting to reduce the attack surface and enable only the features needed to be exposed
- Fully customizable whitelisting and blacklisting by account, IP, wallets or NFT ownership

### Supported Storages

#### Databases

- PostgreSQL
- MongoDB
- MySQL
- SQLite
- InfluxDB
- Microsoft SQL Server
- LevelDB
- RocksDB
- RethinkDB
- CouchDB
- Cassandra
- Riak
- kdb+
- GridDB
- KairosDB
- QuestDB
- QuasarDB
- CockroachDB
- ArangoDB
- YugabyteDB
- Elastic
- TileDB
- Firebase
- Amazon DynamoDB
- Amazon Aurora
- OpenTSDB
- Cloudant
- Oracle

#### File Storages

- local file storage
- Google Big Query
- IPFS
- Amazon S3

#### Supported File Formats

- Raw
- JSON
- CSV
- Feather
- Avro
- Parquet
- ORC
- TOML
- YAML
- Protobuf

#### Supported Blockchains

- internal ledger
- Polygon
- Solana
- Optimism
- Hyperledger Sawtooth
- Hedera
- Ethereum
- Avalanche
- Celo
- Fantom
- Harmony
- Base
- Aurora
- BNB Chain
- Klatyn
- Algorand
- Arbitrum
- Corda
- Polkadot

### Supported Transports

- HTTP and HTTPS
- WS and WSS
- Kafka
- RabbitMQ
- ZeroMQ

#### Supported encryption at rest

Data can be optionally encrypted with an additional layer, besides the [potentially available] encryption at rest of the underlying storage.

Encryption can be enabled at field level

- AES/GCM 
- ChaCha20-Poly1305
 
#### Supported Data Obfuscation Methods

- Erasure
- Redaction (with custom values depending on input)
- Hashing
- Unique Random IDs (consistent within tables)
- Linked Random IDs (consistent across tables)
- Noise Addition
- Quantization, with optional scaling and non-linear transformations, eventually combined with noise addition
- Encryption at read

#### Supported Authentication Methods

Multiple authentication methods can be combined, depending on the needs

- private/public key pair
- verifiable credentials
- wallet ownership (for any of the supported blockchains)
- NFTs ownership
- Zero-Knowledge Proofs
- on-chain direct payments or subscriptions
- on-chain smart contract state or function result
- on-chain token ownership or staking
- email magic link

The authentication methods above can also be used to control access dynamically at row level, meaning that - if a table is configured to have this functionality - a user that has write access to the table can specify the roles that are authorized to read it or custom rules using any of the methods above.

#### Supported Hashes

- SHA-256
- SHA-512
- HmacSHA256
- HmacSHA512
- Keccak-256
- Keccak-512
- Salted Keccak-256
- Salted Keccak-512
- Blake2
- Salted SHA512-SPHINCS256
- Salted XMSS256
- Salted XMSS512

#### Supported Signatures

Weavechain uses secp256k1 for its private/public keys authentication, but also maintains and can handle keys for few other different signature schemes that can be enabled, depending on the needs of the app built on top of the nodes.

- Ed25519
- Threshold Ed25519
- Crystals Dilithium
- Blind RSA Signatures
- BLS

#### Fees

Fees can be configured depending on the use case and there are two major ways to handle them:

1. Paying on-on chain or in a smart contract *before* having access to data or compute
2. Pay as you go

Fees can be configured as:

- one time payments or subscriptions, pre-paid on-chain or based on smart-contract logic
- records count
- records size 
- time based fees
- tiered or capped fees
- compute tasks pricing based on CPU usage or dynamic based on custom logic
