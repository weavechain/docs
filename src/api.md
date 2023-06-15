# API

In order to interact with the Weavechain nodes, the API client connects to one of the nodes that is part of a Weave. 

A client API session needs to know how to connect to the node and is established by authorizing with a private/public key pair. A role-based access control model allows configuring rights in the nodes, assigning roles to accounts (identified by monikers or their public key), and rights to roles (view, create, drop, read, write, compute) up to table level.

Multiple sessions can be created with the same account (eventually asking for different rights).

Full audit of all the operations can be enabled in the nodes (and stored locally or on a remote Weave).

APIs:

- [Java](https://github.com/weavechain/weave-java-api)
- [Javascript](https://github.com/weavechain/weave-js-api)
- [Python](https://github.com/weavechain/weave-py-api)

Pending release:
- [C#](https://github.com/weavechain/)
- [Go](https://github.com/weavechain/)

## <a name="Creating_an_API_client">Creating an API client</a>

Instantiating an API client can using a JSON definition. 

The information needed is:
- the API version
- a sidechain local identifier
- the keys used to authorize (the keys can be specified as inline text or [recommended] as files. The public key can be derived from the private key, but it's recommended to have it in text format as it's the user identifier for all actions in the Weave)
- how to connect to the node: the transport protocol (HTTPS and WSS are supported by all API clients, with the Java API additionally supporting RabbitMQ, Kafka and ZeroMQ)

```json
"chainClientConfig": {
    "apiVersion" : 1,

    "seed" : "92f30f0b6be2732cb817c19839b0940c",
    "privateKeyFile" : "sample.pvk",
    "publicKeyFile" : "sample.pub",

    "http": {
        "host": "public.weavechain.com",
        "port": 443,
        "useHttps": true
    }
}

```

Sample code for creating a client API:

**Javascript**
```js
import WeaveAPI from 'weaveapi'

const nodeApi = WeaveAPI.create(configuration);
await nodeApi.init();
const pong = await nodeApi.ping();
console.log(pong)
```

**Python**
```python
from weaveapi import weaveapi

nodeApi = weaveapi.create(config)

```

**Java**
```java
import com.weavechain.api.ChainApiFactory;

ApiClientV1 nodeApi = ChainApiFactory.createApiClient(configuration);
```

## <a name="Session_management">Session management</a>

Once a client API is created, sessions can be created, logging in to the node and requiring specific access.

During the login, the following information is needed:
- the organization (can be "*" if there are no multiple organizations defined, case in which the field is ignored)
- the account moniker or public key to be used during authentication
- a space separated list of the data collection for which access is required (can be "*" in order to obtain access to all data collections for which the user is authorized)
- optional: credentials. These can be used in order to pass additional information that would make the user inherit rights given through other mechanism.

The supported additional mechanisms are:
- verifiable credentials (the issuer needs to be defined in node configs, specifying what roles or user templates they can delegate and a presentation of the verifiable credentials needs to be issued using the public key to be authorized as a challenge)
- wallet ownership for EVM compatible blockchains or Solana (the wallets can be given rights and the Weavechain keys used during login inherit those rights). The wallet ownership is verified by signing a message (with Metamask or Phantom) that does not involve any blockchain interaction or gas being paid
- NFTs (ERC-721, ERC-1155) or SoulBound Tokens ownership. The NFTs are specified only in the nodes configuration, the client just needs to prove the wallet ownership. Access can be gated based on collection ownership, owning a specific item or, with additional support added in the node, based on NFT traits.

Each session is allocated dynamically a new API key that allows access to the requested data collections. Each message has a nonce and is signed.

A session automatically expires after a period of time that is configured in the node (by default 24 hours).

Once a session was established, all API calls return a JSON structure with the operation result code, the operation target (if any was specified) and the operation reply (and eventually an additional error message). 

### <a name="Login">Login</a>

A weavechain private/public key pair is needed in order to login. Weavechain supports a full RBAC model, an account can be member of multiple organizations and within an organization roles can be assigned based on its public key. A role can give rights (such as read, write, delete, compute) on one or multiple data collections, with granularity up to table level.

In addition to pre-configured user level rights, roles could be inherited based on Verifiable Credentials, wallet ownership or NFT ownership (and traits), with these being passed during login in the optional *credentials* parameter.

The *collections* parameter can be used to create a session that is restricted to work only with specific data (* can be used to get maximum available rights).

**Javascript**
```js
const session = await nodeApi.login(organization, account, collections, credentials);
console.log(session)
```
**Python**
```python
session = nodeApi.login(organization, account, collections, credentials).get()
print(session)

```
**Java**
```java
CompletableFuture<Session> session = nodeApi.login(organization, account collections, credentials);
```

### <a name="Logout">Logout</a>

Logout will remove the current session from the server.

**Javascript, Python, Java**
```
nodeApi.logout(session)
```

### <a name="Check_Session">Check Session</a>

Check session is a helper function to renew the API key in case it's expired. The *credentials* optional parameter can be used to pass verifiable credentials or wallet ownership information during relogin.

**Javascript, Python, Java**
```
nodeApi.checkSession(session, credentials)
```

## <a name="Status_API_calls">Status API calls</a>

### <a name="Version">Version</a>

Returns the remote node API version

**Javascript, Python, Java**
```
nodeApi.version()
```

### <a name="Ping">Ping</a>

Checks the availability of a remote node and returns the [unadjusted] clock on the remote machine

**Javascript**
```
const reply = nodeApi.ping().get();
console.log(reply)
```
**Python**
```
reply = nodeApi.ping().get()
print(reply)
```
**Java**
```
OperationResult reply = nodeApi.ping().get();
```

### <a name="Generate_Keys">Generate Keys</a>

Generates a Weavechain private/public key pair. The keys are returned in compressed base58 format (and the public keys are prefixed with "weave")

**Javascript, Python, Java**
```
nodeApi.generateKeys()
```


### <a name="Get_Client_Public_Key">Get Client Public Key</a>

Returns the public key of the current API client

**Javascript, Python, Java**
```
nodeApi.getClientPublicKey()
```

### <a name="Get_Public_Key">Get Public Key</a>

Returns the public key identifying the remote node to which the API is connected

**Javascript, Python, Java**
```
nodeApi.publicKey()
```

### <a name="Get_Signature_Key">Get Signature Key</a>

Returns the public key used for signing messages by the remote node (such as task lineage). This can be a Ed25519 or a Dilithium public key, depending on the node configuration.

**Javascript, Python, Java**
```
nodeApi.sigKey()
```


## <a name="Data_and_Compute_API">Data and Compute API</a>


### <a name="Get_Status">Get Status</a>

Returns the status of the node to which the API is connected.


**Javascript, Python, Java**
```
nodeApi.status(session)
```

### <a name="Create_Table">Create Table</a>

Creates a table in a specified database or file storage, if user rights are allowing it.

Create operations can have several flags and modifiers passed as options:
- a boolean flag specifying if the operation should fail  or continue without an error if the table already exists
- a boolean flag specifying if the table is replicated or not
- a layout of the table
- an operation timeout

**Javascript, Python, Java**
```
nodeApi.createTable(session, collection, table, options)
```

If no table layout is specified, by default the Weave will create a time series having an *id* column as the primary key, a *data* column to store blobs, a nullable *metadata* column to store additional information and a *ts* column holding a timestamp with the network time of the write operation.

Layouts can specify if a table is available for local access only or if they can be read remotely. Also, they contain details about the columns, their data types, if they are indexed, if they are encrypted (by the node, the encryption at rest of the underlying storage is separate), as well as if they have transformation for PII obfuscation.

Sample create operation of a non-replicated table accessible remotely:

**Python**
```
layout = { 
    "columns": { 
        "id": { "type": "LONG", "isIndexed": True, "isUnique": True, "isNullable": False },
        "name_nickname": { "type": "STRING" },
        "name_last": { "type": "STRING" },
        "name_first": { "type": "STRING" },
        "birthday": { "type": "STRING", "readTransform": "ERASURE" },
        "email_personal": { "type": "STRING", "readTransform": "ERASURE" },
        "phone_number": { "type": "STRING", "readTransform": "ERASURE" },
        "address_country": { "type": "STRING" },
        "address_summary": { "type": "STRING", "readTransform": "ERASURE" },
        "address_timezone": { "type": "STRING" },
        "linkedin_url": { "type": "STRING" },
        "discord_username": { "type": "STRING" },
        "telegram_username": { "type": "STRING" },
        "ethereum_wallet_address": { "type": "STRING" }
    }, 
    "idColumnIndex": 0, 
    "isLocal": False,
    "applyReadTransformations": True
}

collection = "weavedemo"
table = "directory"

nodeApi.createTable(session, collection, table, CreateOptions(False, False, layout))
```

### <a name="Drop_Table">Drop Table</a>

Drops a table in the remote node, if user rights are allowing it.


**Javascript, Python, Java**
```
nodeApi.dropTable(session, collection, table)
```

### <a name="Write_Data">Write Data</a>

Writes a set of records into a table/time series. The simple access API can act in many different ways depending on the options passed and on the nodes configuration.

A write can be replicated or not, offer delivery guarantees, be paid or not, it can be done in a database or a file storage, it can be done in a replicated table or a private non-replicated table.

Batching records can also happen, locally (depending on the client API configuration) or remotely (depending on the node configuration). Batching can be done based on the number of records, their size or a maximum waiting time.

**Javascript, Python, Java**
```
nodeApi.write(session, collection, records, options)
```

The records structure contains the target table and a matrix with the data to be written. 

The options passed can select the behavior of the write and have the following flags:
- guaranteed: if the write can be asynchronous or finishes only after the write replication and hash storage happened
- minAcks: the minimum number of nodes that need to replicate the data before considering the write successful, by default 1
- inMemoryAcks: boolean flag specifying if replicating nodes are allowed to acknowledge a write once they received (and verified) it or only after they persisted it in the local database or file storage, by default false
- writeTimeoutSec: specifies the operation timeout, by default 300 seconds
- allowDistribute: specifies if the operation is to be carried only on the destination node or the write needs to be distributed to peers. It can be overwritten by the node if the data owner does not want to allow this feature. The default value is true.
- signOnChain: boolean flag specifying if the record is to be hashed on chain. This can be overwritten by the node if the data owner does not want to allow this feature. The default value is true.
- syncSigning: boolean flag specifying if the hashes are stored on the blockchain assuring the immutability synchronously or the signing can be done async. The default value is false


### <a name="Read_Data">Read Data</a>

Reads a set of records from a table/time series. The simple API can cover multiple behaviors: the read operations can include immutability checks, can be paid or not (depending on the node configuration) or can be done from a single node or from multiple nodes.

**Javascript, Python, Java**

```
nodeApi.read(session, collection, table, filter, options)
```

The filter supports comparing operations (eq, neq, in, notin, gt, gte, lt, lte, and, or, not), multi-column ordering, limiting the output results count and multi-column collapsing.

Sample:

**Python**

```
filter = Filter(
  FilterOp.opand(
      FilterOp.eq("field1", "something"),
      FilterOp.eq("field2", "something")
  ),
  { "id": "ASC" },
  None, # No limit
  None  # No collapsing
)
```

The options passed can select the behavior of the write and have the following flags:
- verifyHash: a boolean flag that triggers an integrity check done by the node after reading the data. The default value is true, but it is often needed to turn it off or do it only once per session, as the hash checking operation can add slowness as it involves the blockchain. If the node is not trusted to do the check, the hashes could be verified by the client, as they are available on-chain.
- readTimeoutSec: the operation timeout
- peersConsensus: a number of nodes that need to agree with the data. This is an alternate way of checking data integrity in a distributed network (by doing data consensus) or a way to recover the data in case of immutability checks failure. The default value of this setting is 0, meaning that the node to which the API is connected is trusted to return the data. A special value can be used to retrieve data from all nodes that are active.
- enableMux: a boolean flag that specifies if data from multiple nodes is multiplexed or not. Enabling this flag is useful when multiple clients have different non-replicated parts of a shared dataset. The default value is false.
- includeCached: a boolean flag specifying if multiplexed reads can include values cached by a proxy node. In the scenario when nodes have non-replicated information, certain nodes can go off-line, making their data inaccessible. In such cases, to prevent intermittent data presence and if the network configuration allows it, proxy nodes can act as brokers for the data and cache it (in memory) for subsequent requests. This flag is turned off by default.

### <a name="Read_Data_Hashes">Read Data Hashes</a>

Reads the hashes for a set of records from a table. The hashes are generated for batches of records, depending on the local and remote batching settings.

**Javascript, Python, Java**

```
nodeApi.hashes(session, collection, table, filter, options)
```

### <a name="Delete">Delete</a>

Removes a set of records matching a filter from a table/time series. The  API will remove the data in the whole network if the collection is replicated, and re-hash the affected data.

**Javascript, Python, Java**

```
nodeApi.read(session, collection, table, filter, options)
```

The filter supports comparing operations (eq, neq, in, notin, gt, gte, lt, lte, and, or, not), multi-column ordering, limiting the output results count and multi-column collapsing.

### <a name="Download_Table">Download Table</a>

Downloads a subset of a table in a specified format, the result containing a base64 encoding of a zip file.

The downloaded data can be retrieved from a single node or from multiple ones, check for integrity etc.

The filter and options are similar to a read.

Supported formats: csv, json, feather, parquet, avro, orc, protobuf, toml, yaml

**Javascript, Python, Java**

```
nodeApi.downloadTable(session, collection, table, filter, format, options)
```


### <a name="Publish_Dataset">Publish Dataset</a>

Publishes a dataset (snapshot, rolling or live) to be downloaded after paying on chain.

The return value will contain a DID of the dataset, following the did:weave:node:hash format. The hash is an actual hash of the data if the dataset is static, otherwise it's the hash of the data at the moment of creating the dataset.

The chain on which the payments are made and the token specified must be configured in the node.

Multiple chains are supported (and prefixing the token with the name of the configured chain is used to select which one to be used).

NFT gating is also possible, case in which the price will be negative and the token specifies the NFT contract address and, eventually, additional data if the permissioning needs to be for specific NFT IDs or traits.

**Javascript, Python, Java**

```
nodeApi.publishDataset(session, collection, table, filter, format, price, token, options)
```


### <a name="Download_Dataset">Download Dataset</a>

Downloads a previously published dataset, verifying access based on existing blockchain payment or NFT ownership.

**Javascript, Python, Java**

```
nodeApi.publishDataset(session, did, options)
```

### <a name="Subscribe">Subscribe</a>

The subscribe function allows triggering a read operation for a snapshot of the data, as well as subsequent updates in case new records are stored.

A subscription id is returned in the function result.

The options passed are similar as for the read() operation.

Not all multiplexing scenarios are supported for subscribe.

**Javascript, Python, Java**

```
nodeApi.subscribe(session, collection, table, filter, options, updateHandler)
```

### <a name="Unsubscribe">Unsubscribe</a>

Stops an active subscription of data, freeing server and network resources.

**Javascript, Python, Java**

```
nodeApi.unsubscribe(session, subscriptionId)
```

### <a name="Compute">Compute To Data</a>

Triggers a compute task remotely. This is a helper function to use a compute to data confidential compute pattern. 

The name passed is a Docker or WebAssembly image that the client wants to run on the remote node and must be pre-authorized by the data owner and auditing all images before allowing them to run is highly recommended. The compute task should ingest data using the Weavechain API and can be written in any language. It also offers full flexibility in using 3rd party libraries as any code is allowed.

The compute engine needs to be configured in the node where the API is connected and it can spawn a task in a local or remote docker instance, in kubernetes or in-process for WebAssembly tasks.

A compute operation can be paid or not, depending on node configurations  (payments could happen for the data read and for CPU time). Access to compute could also be pre-paid on-chain or gated with NFTs.

There are 3 ways in which a task can generate output information: by writing data to another output table, by returning a task output result or by logging to the console. These outputs can be limited or filtered.

The return value includes a taskId, the task outputs (if any), console logs and signatures. The outputs are signed and there are two types of signing supported, one using Ed25519 signatures of the hash of the outputs or, when the output is a binary PDF, signing with traditional certificates.

Optionally, if the node is configured to sign with quantum resistant hashes, Dilithium signatures will be used instead of Ed25519.

The following options can be specified for a compute operation:

- sync: a boolean flag specifying if the operation is to be performed in a synchronous fashion or async if no direct output is expected
- timeoutSec: the operation timeout
- peersConsensus: a number of nodes (or a special value specifying all active nodes) that need to agree with the output. By default a task is executed only on the node to which the API is connected, but if multiple nodes have a replicated dataset, a consensus can be requested (and the output needs to match and be signed by all nodes participating)
- params: custom parameters that need to be passed to the remote task

**Javascript, Python, Java**

```
nodeApi.compute(session, image, options)
```

Preventing data exfiltration can be configured server side by limiting the output by size, by adding keywords that trigger rejecting releasing the output to the consumer or forcing the output to follow a certain pattern.

### <a name="Verify_Lineage">Verify Lineage Signature</a>

The result of a compute task can contain signatures for the outputs through which the node that performed the task vouches it used inputs having a certain hash, a docker image with another hash and produced the outputs given to the client. 

This functionality can be used to verify the integrity of the output and contains details about all the data that entered the calculation, the hash of the docker image (or compute algo), as well as all the outputs, including the console. One hash is generated for everything that entered the calculation, as well as separate hashes can be produced for each table that was used as input data for the task.

A full lineage detail sample:

```
    {'WEAVE_API_KEY': '8cf20ed5e21b40a0bc4a87ccd8e8ec98ba9ee426e98c7955',
     'taskId': '8fe6dbfd565242629dbf74c4a144d666',
     'input': '[{"hash":"IGA+57y2yLzmeCNUpkeUvTgeNXsXN15KxM7jHLb+c7o=","scope":"private","table":"questionnaire"},{"hash":"LXosgrO1PGi+0e55/0KZLM6G9dypYTdo9oAlJPVP/00=","scope":"private_files","table":"23andme.txt"}]',
     'inputHash': 'X6e2zDacmwN2hfbMbXehC7BxeiCHyhY1Bk826oRrx32',
     'writes': '[{"hash":"iCHCj17+5GHImAdSkX6OQisDRAgsWmkRh7brJrs3lGg=","scope":"private","table":"23andme_results"}]',
     'writesSignature': '5dh1Sh4TrKsweb5dcFamuoQsZAVyvmLREAM1NfcpWzhdzmeV1unQfGueTGh4CqMHqZAdZKJRuZJjA2KzDKAHWHK8',
     'computeHash': '3nw5CzrqaGfysne96Ki5gLFSeEdo1Wj9eVR6YqKMLw49',
     'paramsHash': 'GKot5hBsd81kMupNCXHaqbhv3huEbxAFMLnpcX2hniwn',
     'output': '{"snps": 6}',
     'outputHash': 'HuN4mAHXcDes5DaDoknsKppzwfHGKL8XE3KfgcRNP4rK',
     'outputSignature': 'mWyG3RMDVJfnu5cQP59CwYPFpx8ni7oz7ggVwwP99a21PmwPoivC4kyN2b8yMqPKm2ECk8tWp9kvC7MCXZrPK5U',
     'outputSignatureTs': '2RFmH85HGiZsXsAtKFNij4aYrN8CjBt75k6d6Lsn9DuSL8DV3mnsXo2AJ5T6YWWddfWZAG7bK2HZpUWiaDehXqeN',
     'console': '{"res":"ok","data":"pong 1674308381796"}\nDone.\n',
     'consoleSignature': '4bcAE9V6QFyP3VmaoCizfHmLPhuXf1SnfaKKrjmEL8GWE8SYg5Ua1VbiBuyv2hQGtZzREDGLQ6wtYwFiaqzK65Zo',
     'ts': '1674308385096'}
```
These signatures can be used also in an off-line context, as long as the public signing key of the node is known.

**Javascript, Python, Java**

```
nodeApi.verifyLineageSignature(signature, inputHash, computeHash, paramsHash, data)
```

### <a name="Verify_Signature">Verify Signature</a>

Verifying a random string of data that was signed by the node can be done using this function

**Javascript, Python, Java**
```
nodeApi.verifySignature(signature, data)
```

### <a name="Hash_Checkpoint">Hash Checkpoint</a>

In order to be able to verify the hashes that are returned in the computational lineage, the API needs to have a mechanism to reproduce computing them by a party that has the same data.

The hashCheckpoint() function allows transient auditing of all data inputs and outputs in a session. A first call will enable this feature (which is disabled by default to save resources), and any subsequent call will return a list with all the read and write operations that were performed on that session between the last two checkpoints (including a salted hash of the data handled by each operation), as well as a generic inputHash and outputHash anchoring all data in a single hash, which can be matched against the values returned from a compute task.


**Javascript, Python, Java**

```
nodeApi.hashCheckpoint(signature, enable)
```

### <a name="Homomorphic_Encryption">Homomorphic Encryption</a>

Another confidential compute supported is a 1:1 scenario, where the consumer is running some code locally on his machine on encrypted data coming from the data owner.

The supported encryption scheme is CKKS and the underlying libraries are  SEAL and EVA from Microsoft.

There is an exchange between the consumer and the data owner, with the first one receiving a set of the columns in plain text (if any configured like that, those could be part of aggregation criteria or not critical and exposable), and another set encrypted. The encrypted values can be used to do linear transformations (add, subtract, multipy, divide).

Encrypted values cannot be mixed with unencrypted values, you cannot add an encrypted number with a plaintext one. 

The aggregated results must be sent to the data owner to be decrypted. The data owner will get the outputs, decrypt them and send them to the client only if he agrees to release the results (and size checks or filtering can be applied, to avoid unwanted data exfiltration).
The consumer's code is not revealed to the data owner, and could combine the decisions with some local data that is not revealed to anyone else, but the remote data owner will see the results.


#### <a name="HE_Get_Inputs">HE Get Inputs</a>

This API call returns the inputs needed by a client running homomorphic encryption.

The datasources is a list of arguments used for read() API calls locally by the data owner. 

Depending on the column definitions, data is allowed to be retrieved in plaintext (to be used by the consumer for aggregations or various decisions) or will be encrypted.

The arguments passed can be empty, case in which the plaintext data is retrieved, or the encodings of an EVA program params and signature, case in which the encrypted data is retrieved.

**Javascript, Python, Java**

```
nodeApi.heGetInputs(session, datasources, args)
```

Sample:

**Python**

```
datasources = {
    # encrypted (per server side definition)
    'q': [ collection, table, filter.toJson(), READ_DEFAULT_NO_CHAIN.toJson(), "quote" ],
    't': [ collection, table, filter.toJson(), READ_DEFAULT_NO_CHAIN.toJson(), "timestamp" ],
    # plaintext
    'i': [ collection, table, filter.toJson(), READ_DEFAULT_NO_CHAIN.toJson(), "instrument" ],
}

# Retrieve plaintext inputs
reply = nodeApi.heGetInputs(session, datasources, []).get()

compiled_prog, params, signature = compile(program)


#Retrieve encrypted inputs
reply = nodeApi.heGetInputs(session, datasources, [ eva2str(params), eva2str(signature) ]).get()

```

#### <a name="HE_Encode">HE Encode</a>

Helper API function to allow a consumer to ask the data owner to encrypt custom numeric values with his own key, to be used in operations with other encrypted values.

**Javascript, Python, Java**

```
nodeApi.heEncode(session, items)
```


#### <a name="HE_Get_Outputs">HE Get Outputs</a>

After performing operations on encrypted data, the consumer needs to request the data owner to decrypt the results. This is done via the heGetOutputs function which will pass the encrypted values, the public context and the signature of an EVA program.

**Javascript, Python, Java**

```
nodeApi.heGetOutputs(session, encoded, args)
```

Sample:

**Python**
```
reply = nodeApi.heGetOutputs(session, eva2str(enc_outputs), [ e_public_ctx, eva2str(signature) ]).get()
```


### <a name="MPC">Multi-Party Computing</a>

MPC is a one consumer, many data owners confidential compute scenario, where some pre-defined statistical functions can be executed against a distributed dataset that is split across many owners.

The functions implemented range from descriptive stats and basic things like the distribution moments to linear regression.

The protocol used is SPDZ and Weavechain is using FRESCO from Alexandra Institute for underlying processing.

This is fully secure for the data owner as no unwanted data exfiltration can happen, but data can still be recovered if any number of computation rounds can be done and the input data is limited. That's why, in certain situations, the data owner might want to limit MPC to be available only if at least a number of records are used in the aggregation function, or at least N other parties are involved (from which at least M should be trusted, to avoid collusion to extract the data by the other participants).

This pattern is suitable when there is one consumer and many data owners that have different data following the same structure that can be analyzed by the consumer without seeing it.

The speed of running the protocol increases significantly first with the number of parties, then with the size of the data.

We allow a degenerated form of MPC to run 1:1, which translates into running predefined functions on a private dataset.

The operations supported are: correlation, inner product, linear regression, mean, median, stdev, variance, sum, t-test, two sample wilcoxon test and 2 parties private set intersection.

Although the records are not shared by the data owners, their hashes can be verified during the operation.

The operation can be launched on all active nodes or on a subset of the nodes, specifying them by their public key.

**Javascript, Python, Java**

```
nodeApi.mpc(session, collection, table, algo, fields, filter, options)
```

### <a name="Storage_Proof">Storage Proof</a>

This function can be used to obtain an interactive storage proof from a data owner. Integrity checks using hashes can guarantee the data values once retrieved, but just by checking hashes nodes cannot be checked that they actually hold the data. This function can be used to verify that a node has actual knowledge of the data, assuming the one triggering has a local copy or a dataset hash computed with the challenge.

The functionality can be restricted by the node, to prevent data exfiltration (as the filter can be used to pinpoint to individual records).

Note: the purpose of this function is to provide actual storage proofs, which can be used for immutability checks, but are actually different from the source integrity proofs (that can be achieved by enabling integrity checks and having columns that are automatically filled by the API with hashes and signatures from the source) and the live immutability proofs (which can be achieved by storing hashes of records or a merkle root hash on a blockchain).

```
nodeApi.storageProof(session, collection, table, filter, challenge, options)
```

### <a name="ZK_Storage_Proof">ZK Storage/Data Proof</a>

In order to prevent unwanted data exfiltration, this function can be used to obtain an interactive zero-knowledge proof instead of a hash.

The result of the is a Schnorr NIZK transcript that can be validated by the consumer.

**Javascript, Python, Java**

```
nodeApi.zkStorageProof(session, collection, table, filter, challenge, options)
```

A local proof can also be generated for any set of records or for an arbitrary string.

**Java**
```
nodeApi.zkDataProof(Records records, byte[] challenge)
nodeApi.zkDataProof(String data, byte[] challenge)
```

### <a name="Verify_ZK_Storage_Proof">Verify ZK Storage/Data Proof</a>

Helper function for verifying the transcript of a zk storage or arbitrary data proof generated by another party.

**Java**

```
nodeApi.verifyDataProof(Records data, byte[] challenge, String transcript)
boolean verifyDataProof(String data, byte[] challenge, String transcript)
```

### <a name="Merkle_Tree">Data Merkle Tree</a>

This function can be used to generate a Merkle Tree out of arbitrary data stored in table and is a building block that can be used by applications built using Weavechain. Hashes of the data records are used to build a Merkle Tree, which then can be used to validate data inclusion by parties that know the data hashes.
  
This API call allows building a merkle tree out of partial data by using a filter, which is different from Merkle trees that can be configured to be automatically maintained in real-time by a node for the whole table. 

**Java**

```
nodeApi.merkleTree(session, collection, table, filter, salt, digest, options)
```


### <a name="ZK_Merkle_Tree">ZK Merkle Tree</a>

This function can be used to generate a Merkle Tree out of arbitrary data stored in table and is a building block that can be used by applications built using Weavechain. Hashes of zero-konwledge proofs of the data records are used to build a Merkle Tree, which then can be used to validate data inclusion by parties that can verify the proofs. The function returns the merkle tree and, separately, the data proofs.

**Java**

```
nodeApi.zkMerkleTree(session, collection, table, filter, salt, digest, options)
```

### <a name="Verify_Merkle_Hash">Verify Merkle Hash</a>

Helper function for verifying that a piece of data with a known hash was included in a Merkle Tree or not.

**Java**

```
nodeApi.verifyMerkleHash(tree, hash, digest)
```

### <a name="Verify_Data Signature">Verify Data Signature</a>

Helper function for verifying that a piece of data with a known signer public key is matching a signature. Supported signatures are Ed25519 and Dilithium.

**Java**

```
nodeApi.verifyDataSignature(session, signer, signature, data)
```

### <a name="Merkle_Proof">Merkle Root Hash</a>

This function returns the root hash of a merkle tree for a certain table. It works on merkle trees configured to be maintained in real-time by the node, in contrast with the merkleTree and verifyMerkleHash functions that can be used to build custom trees that could be needed by a user application built on top of Weavechain.

When the merkle trees service is enabled, the root hash is associating a single hash to the content of a whole table and can be configured to be put on a blockchain, offering another immutability proof (the other ones being the hashes of records (or batches) maintained live and which can be anchored on a blockchain, or programatically retrieving a storage proof or zk storage proof).

**Java**

```
nodeApi.rootHash(session, collection, table)
```


### <a name="Merkle_Proof">Merkle Proof</a>

This function can be used to generate a Merkle Proof for a piece of data stored in a table. The merkle proof contains only the hashes needed to validate the inclusion of the specified hash. This function works on merkle trees configured to be maintained in real-time by the node.

**Java**

```
nodeApi.merkleProof(session, collection, table, hash)
```

### <a name="Verify_Merkle_Hash">Verify Merkle Proof</a>

Helper function for verifying that a piece of data with a known hash was included in a Merkle Tree or not, using a proof. This function works on merkle trees configured to be maintained in real-time by the node

**Java**

```
nodeApi.verifyMerkleProof(recordHash, proof, rootHash)
```


### <a name="Bulletproofs">Non-Interactive ZK Proofs for Data</a>

This function implements non-interactive zero knowledge proofs for data using Bulletproofs.

There are 3 flavours, one that allows generating ZK proofs for each value of a column of the data, one which allows generating a batch proof for all records and one which allows generating Bulletproofs for a user specified set of values.

**Javascript, Python, Java**

```
nodeApi.zkProof(session, collection, table, gadget, params, fields, filter, zkOptions)
boolean zkDataProof(session, gadget, params, values, zkOptions)
```

There are multiple gadgets supported: numbers_in_range, number_is_positive, numbers_are_positive, number_is_greater_or_equal, number_is_less_or_equal, number_is_not_equal, number_is_non_zero, numbers_are_non_zero, number_is_zero, number_is_equal, number_in_list, number_not_in_list, mimc_hash_preimage, mimc_string_hash_preimage



### <a name="Verify_Bulletproofs">Verify Non-Interactive ZK Proofs for Data</a>

This function allows verifying the data proofs.

**Java**
```
nodeApi.verifyZkProof(proof, gadgetType, params, commitment, nGenerators)
```


In case a node can be trusted to verify the proof, this operation can be delegated to be performed remotely

**Javascript, Python, Java**

```
nodeApi.verifyZkProof(session, proof, gadget, params, commitment, nGenerators)
```

## <a name="Lineage_API">Lineage API</a>

Consumers to get information about the data and computation lineage, tracking changes and transformations, with guarantees from the data owners.

Data lineage is achieved by storing full audit records for all data operations, including reads.

Compute lineage is achieved by creating a chain of hashes and signatures: a hash is computed for all the input data that is read using the Weavechain API (and the order of operations matters), a hash of the docker image that is executed is used to identify the compute task and a hash of all the outputs that are written using the Weavechain API is also generated. The task output is also hashed and a signature is added by the node that did the computation, vouching for the results.

A task can generate outputs by by returning a task output or by writing to tables using the API.

[Section still under development, more functions to be added]

### <a name="History">History</a>

Returns all the read, write, delete operations on a set of records from a table, matching a filter (or all the table operations if the filter is not specified)

**Javascript, Python, Java**

```
nodeApi.history(session, collection, table, filter, options)
```


### <a name="Task_Lineage">Get Task Lineage</a>

Given an id of a compute to data task, this function returns:
- the hashes of all the inputs that were read using the Weavechain API
- the hash of the docker image executed
- the hash of all the records that were writtten using the Weavechain API
- a summary of all the writes, what tables were affected and the hashes of the records written
- the task output result
- a signature of the writes
- a signature of the output

**Javascript, Python, Java**

```
nodeApi.taskLineage(session, taskId)
```

### <a name="Verify_Task_Lineage">Verify Task Lineage</a>

This function verifies lineage details (the result of a get task lineage) by the node to which the API is connected, returning true if the node acknowledges that the lineage was generated by it.

**Javascript, Python, Java**

```
nodeApi.verifyTaskLineage(session, lineageData)
```

### <a name="Task_Output">Retrieve Task Output Data</a>

This function can be used to retrieve an archive with all the records that were written by a task. The result contains the actual data of all the writes (base64 encoded), the hash of the data and signatures from the node.

The options allow specifying the output format (which can be any of the file formats supported for download).

**Javascript, Python, Java**

```
nodeApi.taskOutputData(session, taskId, options)
```

## <a name="Feeds_API">Feeds API</a>

The functions in this section are a way to automate deploys of Web3 oracles to be used for pushing data on-chain. 

By doing an oracle deploy and a feed deploy, data that is written to a table can be streamed live on chain (or with a configured cadence).

### <a name="Deploy_Oracle">Deploy Oracle</a>

This is a minimal function that automates oracle deployment, making it easy for Weaves to egress data to blockchains. 

The oracle currently supported for automated deploy is chainlink, with few more under development.

The options allow passing custom parameters to specify the owner, costs etc.

The parameters are still subject to changes as we normalize access to multiple oracles.


**Javascript, Python, Java**

```
nodeApi.deployOracle(session, oracleType, targetBlockchain, source, options)
```


### <a name="Deploy_Feed">Deploy Feed</a>

Deploy feed is similar to a compute task and allows starting a generic service that is to be used as a data feed by an oracle. The webserver will be launched a as a docker image on the node's machine.

The return value is a feed identifier that can be used to control the service.

**Javascript, Python, Java**

```
nodeApi.deployFeed(session, image, options)
```

### <a name="Remove_Feed">Remove Feed</a>

Stops and removes a feed that was previously deployed.

**Javascript, Python, Java**

```
nodeApi.removeFeed(session, feedId)
```

### <a name="Start_Feed">Start Feed</a>

Starts a data feed to be used as a Web2 source of truth for an oracle

**Javascript, Python, Java**

```
nodeApi.startFeed(session, feedId)
```

### <a name="Stop_Feed">Stop Feed</a>

Stops a feed.

**Javascript, Python, Java**

```
nodeApi.stopFeed(session, feedId)
```


## <a name="Verifiable_Credentials_API">Verifiable Credentials API</a>

The credentials API functions offer an easy way to generate credentials and presentations following the W3C standard, as well as verifying them.

These credentials can be used in any context, even off-line, assuming the public key of the issuer is known.

Verifiable credentials can be used in Weavechain for obtaining data access by generating presentations from an issuer that is permissioned to delegate rights.

### <a name="Issue_Credentials">Issue Credentials</a>

The function generates a new verifiable credential for a custom payload. Weavechain acts as a generic verifiable credentials issuer, this function is a helper that can be used by dApps built on top to handle their own logic by controlling what that payloads contains.

The credentials are intended to be private.

The options allow to specify additional flags, such as:

- the credential expiration timestamp
- the operation timeout

**Javascript, Python, Java**

```
nodeApi.issueCredentials(session, issuer, holder, credentials, options)
```

### <a name="Verify_Credentials">Verify Credentials</a>

This function validates the verifiable credentials. The verification is done remotely in this case, but it can also be done locally, by checking the signatures.

**Javascript, Python, Java**

```
nodeApi.verifyCredentials(session, credentials, options)
```

### <a name="Create_Presentation">Create Presentation</a>

Once a set of verifiable credentials is held by a person, a presentation can be generated, showcasing only a partial subset of the information for which the original signer vouched. 

The presentations are intended to be public.

The subject specifies a key from the payload, pointing to the subset of information that will be public. A presentation is generated without adding a signature to it, in order to do that, see the Sign function below.

**Javascript, Python, Java**

```
nodeApi.createPresentation(session, credentials, subject, options)
```

### <a name="Sign_Presentation">Sign Presentation</a>

This function signs a presentation, adding a signature from the current node certifying the integrity of the data.

The presentation can contain a domain (specifying what's the indended usage of the presentation) as well as an optional challenge.

**Javascript, Python, Java**

```
nodeApi.signPresentation(session, presentation, domain, challenge, options)
```

Presentations can be used to certify accounts ownership, login to 3rd party services or for identity proofs.

Usage sample: during login(), Weavechain allows specifying additional credentials. By using the public key of a newly created session as a challenge, we can have  newly created key pairs to inherit rights using verifiable credentials. This allows writing backends on top of Weavechain where people can be in charge of the authentication mechanism, instead of using the standard private/public key.

### <a name="Verify_Presentation">Verify Presentation</a>

This function validates a presentation. The verification is done remotely by the node to which the API is connected, but it can also be done locally, by checking the signatures.

**Javascript, Python, Java**

```
nodeApi.verifyPresentation(session, presentation, domain, challenge, options)
```

## <a name="Messaging_API">Messaging API</a>

The messaging API has the role of enabling Weavechain API users to build interactive dApps. Its purpose is to provide a simple messaging mechanism between API sessions.

The exchange of information between dApps can also be done using regular read and write operations in a table, which also offers persistence and full audit. The messaging API is intended to be used for transient communications.

In order to be able to communicate with another session, one needs to know its ID and the other API client to be connected to the same node.  

Messages have a maximum time to live (24h by default) are sent to inboxes, each one having a limit (1000 by default).

This feature is subject to changes as it still evolves.

### <a name="Post_Message">Post Message</a>

This posts a message from the current session to another API session, whose identifier is used as the target inbox.

The message options allow specifying:
- the operation timeout
- the message maximum time to live

**Javascript, Python, Java**

```
nodeApi.postMessage(session, targetInboxKey, message, options)
```

### <a name="Poll_Messages">Poll Messages</a>

This function retrieves all messages received by the current session from another session, identified by its key. A null value for the inbox key will retrieve all messages received, no matter the originator

**Javascript, Python, Java**

```
nodeApi.pollMessages(session, inboxKey, options)
```

## <a name="Admin_API">Admin API</a>

### <a name="Status">Status</a>

Retrieves the status of the node

**Javascript, Python, Java**

```
nodeApi.status(session)
```

### <a name="Get_Sidechain_Details">Get Sidechain Details</a>

Retrieves details about a sidechian, such as its seed, name, description, logo.

**Javascript, Python, Java**

```
nodeApi.getSidechainDetails(session)
```

### <a name="Get_Account_Details">Get Account Details</a>

Retrieves details about a user, such as rights, name, avatar.

**Javascript, Python, Java**

```
nodeApi.getUserDetails(session, publicKey)
```

### <a name="Get_Nodes">Get Nodes</a>

Retrieves the list of active nodes about which the node to which the API is connected knows about.

Nodes can have 3 types:
- active nodes: to which the remote node has direct connections
- passive nodes: which are connected to the remote node but to which the node is not able to initiate a connection (such as nodes behind a firewall)
- proxied nodes: nodes that are not connected to the current node, but which are known to other nodes in the neighbourhood. Their messages can be forwarded (encrypted) by proxy nodes and the replication or MPC can work as if they are part of the network.

**Javascript, Python, Java**

```
nodeApi.getNodes(session)
```

### <a name="Get_Collections">Get Collections</a>

Retrieves a list of the data collections known to the node. The list contains only the collections for which the user initiating the call has "view" rights.

Data collections can have different underlying methods of persisting, such as databases (Postgres, MySQL, SQLite, Cassandra etc.) or file storages (local, S3, IPFS).

**Javascript, Python, Java**

```
nodeApi.getScopes(session)
```

### <a name="Get_Tables">Get Tables</a>

Returns the list of tables available and visible to the user in a data collection.

**Javascript, Python, Java**

```
nodeApi.getTables(session, collection)
```


### <a name="Get_Table_Definition">Get Table Definition</a>

Returns a table layout, which contains the name of the columns, their data type, if they are indexed, unique, nullable, encrypted or if there are any data transformation applied when reading the data by people that are not the data owners.

**Javascript, Python, Java**

```
nodeApi.getTableDefinition(session, collection, table)
```


### <a name="Get_Node_Config">Get Node Config</a>

Returns a JSON with the node configuration. Only the node owner is allowed to retrieve the configuration.

**Javascript, Python, Java**

```
nodeApi.getNodeConfig(session, nodePublicKey)
```


### <a name="Get_Account_Notifications">Get Account Notifications</a>

Retrieves a list of notifications for the user. This list can include integrity warnings or voting that needs to happen in order to change network configurations.

[This feature is still under development]

**Javascript, Python, Java**

```
nodeApi.getAccountNotifications(session)
```

### <a name="Create_User_Account">Create User Account</a>

This function allows permissioning a new account dynamically. A list of roles can be assigned to the user. 

The account monikier is optional, the public key can be used instead.

**Javascript, Python, Java**

```
nodeApi.createUserAccount(session, organization, account, publicKey, roles)
```


### <a name="Update_Table_Definition">Update Table Definition</a>

This function allows changing a table layout, such as specifying encryption for fields, marking fields if they are allowed to be sent as plain text or only encrypted on homomorphic encryption calls, if fields are PII and need to be obfuscated (and how), if a table is private and accessible only locally or it can be read remotely etc.

For a sample layout, see the [Create Table](#Create_Table) function.

Certain table definition changes for replicated collections require the whole network consensus.

[This section behavior is still subject to change]


**Javascript, Python, Java**

```
nodeApi.updateLayout(session, collection, table, layout)
```

### <a name="Update_Config">Update Config</a>

Generic function to allow updating any section of a config, assuming the caller is a node owner.

Certain config changes for replicated collections require the whole network consensus.

Once a node starts, it retrieves the file configuration and stores it to an internal table. Any subsequent configuration changes are stored in that time series and include a signature from the originator.

[This section behavior is still subject to change]

**Javascript, Python, Java**

```
nodeApi.updateConfig(session, path, values)
```

## <a name="Layer-1_API">Layer-1 API</a>

The Weavechain Layer-1 is a ledger that can be used internally by Weaves to store hashes and record micropayments. Its goals are to offer free micropayments inside a private data sharing network and to offer an alternative to blockchains that require more complicated setups when the hashes are stored in a trusted private network. It is also used for achieving faster performance for hashes storage as the ledger can live in the same process with the data nodes and avoids serialization/deserialization of smart contract states on remote blockchains.

The internal payments can be handled in any ERC-20 token, the bridging tokens from a remote blockchain happening with the help of a smart contract deployed on the remote chain.

A small set of internal smart contracts are deployed on the internal chain.

[This section is still under heavy development]

### <a name="Query_Balance">Query Balance</a>

Retrieves the balance of an account in a certain token. The balances are global, but might be distributed per data collection in the future.

**Javascript, Python, Java**

```
nodeApi.balance(session, account, collection, token)
```

### <a name="Transfer">Transfer</a>

Transfers an amount in a certain token to another address defined on the Layer-1.

**Javascript, Python, Java**

```
nodeApi.transfer(session, account, collection, token, amount)
```

### <a name="Call_Contract_Method">Call Contract Method</a>

A generic function to call any smart contract function.

**Javascript, Python, Java**

```
nodeApi.call(session, contract, collection, fn, data)
```


### <a name="Query_Contract_State">Query Contract State</a>

Returns a serialization of a smart contract state. The main usage of contracts is to store hashes details. A contract can have a different state for each data collection.

**Javascript, Python, Java**

```
nodeApi.contractState(session, contract, collection)
```


### <a name="Update_Fees">Update Fees</a>

Updates the fees for a data collection, if the caller is the owner.

The fees can be defined up to table level and charged per number of records, per their size (serialization dependent), per unit of time, capped or not capped.

The fee token is defined by data collection.

**Javascript, Python, Java**

```
nodeApi.updateFees(session, collection, fees)
```

Sample fees format where writers are given 1 token for each record and readers are charged 1 token for each record:

```
{ "fees":
    [
        {"operation":"read", "fee": {"count":"1", "fee": 1, "type":"count"} },
        {"operation":"write","fee": {"count":"1","fee": -1,"type":"count"} }
    ]
}
```
