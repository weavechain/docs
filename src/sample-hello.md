## Hello World


#### Javascript

Import the API library

```javascript
import { WeaveAPI, WeaveHelper } from "@weavechain/weave-js-api"
```

#### 1. Create a new session, then write a message

(hover the code block and click ⏵ to run it)

```javascript,editable
// Generate a key pair
const [ pub, pvk ] = WeaveHelper.generateKeys();
console.log("Public key: ", pub);
console.log("Private key: ", pvk);

// Connect to a public node (that is configured to allow writes from anyone)
const node = "https://public.weavechain.com:443/92f30f0b6be2732cb817c19839b0940c";
const organization = "weavedemo";
const encrypted = node.startsWith("http://");

// Create a new session	
const cfg = WeaveHelper.getConfig(node, pub, pvk, encrypted)

const nodeApi = new WeaveAPI().create(cfg);
await nodeApi.init();

// Write a new record in a pre-defined table 
// hosted by the public node in an SQLite database
// Note: the table is public for this example, but it could have full RBAC
const scope = "shared";
const table = "hello";
	
const session = await nodeApi.login(organization, pub, scope || "*");

// The target table can optionally have some special columns that are auto-filled by the backend
const record = [
        null, //id, filled server side
        null, //timestamp, filled server side
        null, //writer public key, filled server side
        null, //signature, filled server side
        null, //writer IP, filled server side. Erasure is applied to obfuscate it on read
        "*",  //row level read access control (could be roles, accounts, blockchain wallets, NFTs etc.)
        "Hello World!"
    ];
const records = new WeaveHelper.Records(table, [ record ]);
await nodeApi.write(session, scope, records, WeaveHelper.Options.WRITE_DEFAULT);
```


#### 2. Create a new session, read the last inserted record

```javascript,editable
const [ pub, pvk ] = WeaveHelper.generateKeys();
console.log("Public key: ", pub);
console.log("Private key: ", pvk);

// Connect
const node = "https://public.weavechain.com:443/92f30f0b6be2732cb817c19839b0940c";
const organization = "weavedemo";
const encrypted = node.startsWith("http://");

// Create a new session	
const cfg = WeaveHelper.getConfig(node, pub, pvk, encrypted)

const nodeApi = new WeaveAPI().create(cfg);
await nodeApi.init();

const scope = "shared";
const table = "hello";
	
const session = await nodeApi.login(organization, pub, scope || "*");

// Read the last record
const limit = 1;
const filter = new WeaveHelper.Filter(null, {"id": "DESC"}, limit, null, null, null);
const result = await nodeApi.read(session, scope, table, filter, WeaveHelper.Options.READ_DEFAULT_NO_CHAIN);
console.log(result);
```
