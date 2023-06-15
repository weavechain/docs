## Connecting a local database

### Install docker images

- Install a Weavechain node locally if not done already, the easiest way is by starting it as a [docker](./docker.md)
- Install a local jupyter [jupyter server](./jupyter.md) to connect to the node (if not done already)
- Allow running local docker images by running 
```sh
  docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 0.0.0.0:2375:2375 bobrik/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
```

### Prepare the data

- go to the folder where the node was installed, download the [sample.csv](https://public.weavechain.com/file/sample.csv) and save it under storage/files/private_files, or do it from command line
```sh
  cd storage/files/private_files
  curl -O https://public.weavechain.com/file/sample.csv  
```

### Run the notebook

- make sure both the node and jupyter server dockers are running
- connect to the local jupyter server [http://127.0.0.1:18888/notebooks/sample-localdb.ipynb](http://127.0.0.1:18888/notebooks/sample-localdb.ipynb)
- use the token taken from the weave_jupyter_public docker logs
- OR, if you're not using the provided docker server, download the notebook from [here](https://public.weavechain.com/file/sample-localdb.ipynb) and run it in your locally configured jupyter server
- run the cells one by one, in case of errors check for the docker images running properly and without errors in their logs and for the ports being open
- contact us on [Telegram](https://t.me/weavechain_support) or via email [support@weavechain.com](mailto:support@weavechain.com)
- see below a non-interactive output of how the notebook should look like

## Sample of expected notebook:
---

In this demo notebook we will showcase connecting a local database

### 1. Create an API session


```python
import pandas as pd

from weaveapi.records import *
from weaveapi.options import *
from weaveapi.filter import *
from weaveapi.weaveh import *

WEAVE_CONFIG = "config/demo_client_local.config"
nodeApi, session = connect_weave_api(WEAVE_CONFIG)

data_collection = "localdb"
table = "oncology_data"
```

    {"res":"ok","data":"pong 1674727453166"}


### 2. Install a local database (if not already having one)

- it can be any database or file storage from the ones [supported](https://www.weavechain.com/integrations)
- for the example we will assume a local postgres server is installed
- or you can start a new postgres instance as a docker following the "How to use this image" step from [here](https://hub.docker.com/_/postgres). Sample:
```
  docker run --name some-postgres -p 0.0.0.0:5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

#### Create a table and populate it with data

- go to the folder where the node is installed
- download a sample file
```
  curl -O https://public.weavechain.com/file/sample.csv
```
- start the psql command prompt
```
  psql -U postgres -d postgres -h localhost -p 5432
```
- if psql is not available, install it (see [this](https://www.timescale.com/blog/how-to-install-psql-on-mac-ubuntu-debian-windows/) guide from timescale) or run it from docker
```
  docker run -it postgres /bin/bash -c "psql -U postgres -d postgres -h host.docker.internal -p 5432"
```
- ideally create a new database and user, but to simplify the steps we'll use the default *postgres* database and user
- in the psql prompt, create a new table
```
  CREATE TABLE "oncology_data" ("id" BIGINT NOT NULL,"name" TEXT,"age" NUMERIC,"gender" NUMERIC,"air_pollution" NUMERIC,"alcohol_use" NUMERIC,"dust_allergy" NUMERIC,"occupational_hazards" NUMERIC,"genetic_risk" NUMERIC,"chronic_lung_disease" NUMERIC,"balanced_diet" NUMERIC,"obesity" NUMERIC,"smoking" NUMERIC,"passive_smoker" NUMERIC,"chest_pain" NUMERIC,"coughing_of_blood" NUMERIC,"fatigue" NUMERIC,"weight_loss" NUMERIC,"shortness_of_breath" NUMERIC,"wheezing" NUMERIC,"swallowing_difficulty" NUMERIC,"clubbing_of_fingernails" NUMERIC,"frequent_cold" NUMERIC,"dry_cough" NUMERIC,"snoring" NUMERIC,"level" NUMERIC, CONSTRAINT pk_oncology_data PRIMARY KEY ("id"));
```
- and, in the same psql prompt, populate it with data (keep the \ at the beginning)
```
  \COPY oncology_data FROM 'sample.csv' DELIMITER ',' CSV HEADER;
```

### 3. Add a new connection in the configuration file

- go to the node installation folder and edit config/demo.config
- add a new item in the **databases** section
```
  'localdb': {
    'connectionAdapterType': 'pgsql',
    'replication': {
        'type': 'none',
        'allowedCachingIntervalSec': 604800
    },
    'jdbcConfig': {
      'host': 'host.docker.internal',
      'port': 5432,
      'schema': 'public',
      'database': 'postgres',
      'user': 'postgres',
      'pass': 'mysecretpassword'
    }
  },
```
- If the node was started from docker, the address must point to the docker host machine, **host.docker.internal** will work on MacOS and windows. Use **localhost** if the node was started as standalone rather than a docker. Or the internal IP obtained via ipconfig/ifconfig. On linux 172.17.0.1 can also be used most of the time (usually assigned for the host machine to be visible from the docker if it's the single docker network interface)

#### Flag the node to reload the configuration file from disk

- execute the following command in the notebook

```python
reply = nodeApi.resetConfig(session).get()
print(reply)
```

    {'res': 'ok', 'data': 'weaveconfig/demo.config'}


#### Restart the node

- run from the command prompt
```
  docker stop weave_node
  docker start weave_node
```

### 4. Read data from the newly added table


```python
nodeApi, session = connect_weave_api(WEAVE_CONFIG)

reply = nodeApi.read(session, data_collection, table, None, READ_DEFAULT_NO_CHAIN).get()
#print(reply)
df = pd.DataFrame(reply["data"])

df.head()
```

    {"res":"ok","data":"pong 1674727467726"}





<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>name</th>
      <th>age</th>
      <th>gender</th>
      <th>air_pollution</th>
      <th>alcohol_use</th>
      <th>dust_allergy</th>
      <th>occupational_hazards</th>
      <th>genetic_risk</th>
      <th>chronic_lung_disease</th>
      <th>...</th>
      <th>fatigue</th>
      <th>weight_loss</th>
      <th>shortness_of_breath</th>
      <th>wheezing</th>
      <th>swallowing_difficulty</th>
      <th>clubbing_of_fingernails</th>
      <th>frequent_cold</th>
      <th>dry_cough</th>
      <th>snoring</th>
      <th>level</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>Lorenzo Rasmussen</td>
      <td>33</td>
      <td>1</td>
      <td>2</td>
      <td>4</td>
      <td>5</td>
      <td>4</td>
      <td>3</td>
      <td>2</td>
      <td>...</td>
      <td>3</td>
      <td>4</td>
      <td>2</td>
      <td>2</td>
      <td>3</td>
      <td>1</td>
      <td>2</td>
      <td>3</td>
      <td>4</td>
      <td>1</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>Zechariah Gallegos</td>
      <td>17</td>
      <td>1</td>
      <td>3</td>
      <td>1</td>
      <td>5</td>
      <td>3</td>
      <td>4</td>
      <td>2</td>
      <td>...</td>
      <td>1</td>
      <td>3</td>
      <td>7</td>
      <td>8</td>
      <td>6</td>
      <td>2</td>
      <td>1</td>
      <td>7</td>
      <td>2</td>
      <td>2</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>Lukas Jenkins</td>
      <td>35</td>
      <td>1</td>
      <td>4</td>
      <td>5</td>
      <td>6</td>
      <td>5</td>
      <td>5</td>
      <td>4</td>
      <td>...</td>
      <td>8</td>
      <td>7</td>
      <td>9</td>
      <td>2</td>
      <td>1</td>
      <td>4</td>
      <td>6</td>
      <td>7</td>
      <td>2</td>
      <td>3</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>Trey Holden</td>
      <td>37</td>
      <td>1</td>
      <td>7</td>
      <td>7</td>
      <td>7</td>
      <td>7</td>
      <td>6</td>
      <td>7</td>
      <td>...</td>
      <td>4</td>
      <td>2</td>
      <td>3</td>
      <td>1</td>
      <td>4</td>
      <td>5</td>
      <td>6</td>
      <td>7</td>
      <td>5</td>
      <td>3</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>Branson Rivera</td>
      <td>46</td>
      <td>1</td>
      <td>6</td>
      <td>8</td>
      <td>7</td>
      <td>7</td>
      <td>7</td>
      <td>6</td>
      <td>...</td>
      <td>3</td>
      <td>2</td>
      <td>4</td>
      <td>1</td>
      <td>4</td>
      <td>2</td>
      <td>4</td>
      <td>2</td>
      <td>3</td>
      <td>3</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 26 columns</p>
</div>



### 5. Make the table private


```python
reply = nodeApi.getTableDefinition(session, data_collection, table).get()
#print(reply)
layout = json.loads(reply["data"])["layout"]
layout["isLocal"] = True
reply = nodeApi.updateLayout(session, data_collection, table, json.dumps({ "layout": layout})).get()
print(reply)
```

    {'res': 'ok', 'target': {'operationType': 'UPDATE_LAYOUT', 'organization': 'weavedemo', 'account': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg', 'scope': 'localdb', 'table': 'oncology_data'}}


#### and fail to read the data

- we expect a **Not authorized** reply here


```python
reply = nodeApi.read(session, data_collection, table, None, READ_DEFAULT_NO_CHAIN).get()
print(reply)
```

    {'res': 'err', 'target': {'operationType': 'READ', 'organization': 'weavedemo', 'account': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg', 'scope': 'localdb', 'table': 'oncology_data'}, 'message': 'Not authorized'}


### 6. Compute a Merkle Tree from a subset of columns in the private table


```python
salt = "salt1234" # Same salt used for records hashes, this can be improved to have different salts for *each distinct writer*

filter = Filter(None, None, None, None, [ "name", "age" ])
reply = nodeApi.merkleTree(session, data_collection, table, filter, salt, READ_DEFAULT_NO_CHAIN).get()
tree = reply["data"]["tree"]
rootHash = reply["data"]["rootHash"]
ts = reply["data"]["timestamp"]
rootHashSignature = reply["data"]["signature"]

print("Generated at", ts)
print("Root Hash", rootHash)
print("Signature", rootHashSignature)
print("")
print(tree[:400] + "..." + tree[-400:])
```

    Generated at 1674727577162
    Root Hash iax9Vpupq3bXG3DnBTQyKdWr2s3Uh4Q6qcZAPNVJAgb
    Signature 4RdBCQgKWfJqCvD7PrEkYyWSR3KtT8S8eYTdyveDyLFA6RNiwp28R1LvuEtMPAw8ceRzjNddQvQhKFQiRFy9nZoL
    
    iax9Vpupq3bXG3DnBTQyKdWr2s3Uh4Q6qcZAPNVJAgb;SH3Ch1Jwxcs363PwaCYvREgmPVfqr8NcPovZNgXa4js,FE8mTPPJ3uDXTJNxppNa4CeHvfu2Zeo9sjeL71YS12zK;HKgnz9cLoWn4nDapvnGm6K6gH6H5Y2rrgMguaMoKgyek,7s52zKzog488LkgMdEKrkFRoF8opVB9AdrDKtSdSF92j,9tnJTNhSKpZmDViGXtPB2SpoiozEpGkFVNk7FgtLtBQv,A5tNHAHQs61pSzqLJbT9v2ca8ix53kNzzDXKSZ9b6HFy;7oyQ7nq5bLX4J9Es6GQdZcxUpc8FetPZLeyJVFpEnydd,BybqudmZBw54NJhebTWt8yJMf4ar6jnxLRhD2MFsZ7...DhvjP86uY7x4eK7QRrcocBct5XJNGsVUWWREc6zd,E9QLrZqb5M6oXoEQpQ3B5KMvmHJ13Xdb9jUxRgJ3FaJA,F7dfae6vFLs3a2a2w9uET87Euw2uxE2qssvqYcmHPUeP,5Am75Eu1NYQbLuEfTTGDUiH5sWhPcumC3deC4yVYpYkn,HrsDMUrxxgjoXrfeMfSaks8mGK6hbDnyDQjhZwuXnCT7,DL96tTVtfEyRCZCv3EeNd4cStYqX4hR8r5anUi8eAMcC,Gaocem33txtM2KMJbUaMGrEDFrYH1H1oJB25Qb565Ao2,7u4EXgwGPmoqgz6cvAFyfvjAP7cvJcBeHwrK9XpYz9RZ,FpT72W53qoU3YXAZg1DKMCUVSpyLmjA6j52nSXYR9yRn


#### Check root hash signature


```python
toSign = rootHash + " " + ts
check = nodeApi.verifySignature(rootHashSignature, toSign)
print("Check signature:", check)
```

    Check signature: True


#### Verify the presence of a known record in the dataset


```python
row = [ 'Lorenzo Rasmussen', 33.0 ]
recordHash = nodeApi.hashRecord(row, salt)
print(recordHash)
```

    ARMe28cMdZvxBCYgBSALyncPnec4ijERrn2cDJgwgEHA



```python
reply = nodeApi.verifyMerkleHash(session, tree, recordHash).get()
print(reply["data"])
```

    true


### 7. Train a ML model on the private data hosted in our local database

- we do it similarly how it is done in the [Compute Sample](sample-compute.md), where we also check the model lineage
- run on the node machine
```
  docker pull gcr.io/weavechain/oncology_xgboost:latest
```
- use latest-arm64 if your machine is ARM
- the data owner needs to purposely enable running a certain image
- the node needs to be able to connect to the local docker instance
- in the default configuration file installed with the node, the sample script is pre-authorized with the following line
```
  'allowedImages': [ 'gcr.io/weavechain/oncology_xgboost' ]
```
- in case of error, uncomment the #print(reply) below to see details
- (compute to data is just one of the patterns of confidential computing supported, MPC and Homomorphic Encryption could also be used)


```python
reply = nodeApi.compute(session, "gcr.io/weavechain/oncology_xgboost", COMPUTE_DEFAULT).get()
#print(reply)
print(reply["data"]["output"][:1200] + "...")
```

    {"model": "YmluZgAAAD8XAAAAAwAAAAEAAAAAAAAAAQAAAAcAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOAAAAAAAAAG11bHRpOnNvZnRwcm9iBgAAAAAAAABnYnRyZWUsAQAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAsAAAAAAAAAAAAAABcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8BAAAAAgAAAAIAAIAAAJBAAAAAgAMAAAAEAAAACgAAgAAAYEAAAAAABQAAAAYAAAAJAACAAADwQAEAAIAHAAAACAAAABYAAIAAAKBAAQAAAAkAAAAKAAAACQAAgAAAIEACAACA//////////8AAAAA1mVlvgIAAAD//////////wAAAADmFLw+AwAAgP//////////AAAAAEGE5D4DAAAA//////////8AAAAA5RlPvgQAAID//////////wAAAADkGc8+BAAAAP//////////AAAAAG0+Y779nEdD4zjeQ1p2i70AAAAASfgoQ3EcU0P6hyI/AAAAAGRhoUFUVWlDjUE0vwAAAADk9SNC4zgCQycHqz8AAAAAz+gWQhzHoUJlQ/6+AAAAAAAAAACN42RDMio/vwAAAAAAAAAA4ziOQBW8nD8AAAAAAAAAAKqq8kI2br4/AAAAAAAAAADjOA5BlJUsvwAAAAAAAAAA4zgOQZOVrD8AAAAAAAAAAP//j0KwXj2/AAAAAAEAAAAVAAAAAAAAA...

