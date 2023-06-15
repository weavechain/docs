## Hello World

### Install docker images

- Install a Weavechain node locally if not done already, the easiest way is by starting it as a [docker](./docker.md)
- Install a local jupyter [jupyter server](./jupyter.md) to connect to the node (if not done already)

### Run the notebook

- make sure both the node and jupyter server dockers are running
- connect to the local jupyter server [http://127.0.0.1:18888/notebooks/hello-world.ipynb](http://127.0.0.1:18888/notebooks/hello-world.ipynb)
- use the token taken from the weave_jupyter_public docker logs
- OR, if you're not using the provided docker server, download the notebook from [here](https://public.weavechain.com/file/hello-world.ipynb) and run it in your locally configured jupyter server
- run the cells one by one, in case of errors check for the docker images running properly and without errors in their logs and for the ports being open
- contact us on [Telegram](https://t.me/weavechain_support) or via email [support@weavechain.com](mailto:support@weavechain.com)
- see below a non-interactive output of how the notebook should look like


## Sample of expected notebook:
---

In this demo notebook we will showcase a self-sovereign data scenario:

- we will create a table in a shared data collection, that can be read by anyone in the network
- mark some fields as personal information that is not to be shared
- write a record
- read it locally (and be able to see all fields)
- read all records from a remote server
   
The default Weavechain node installation is preconfigured to support this scenario (by connecting to a public weave, having a *shared* data collection defined and mapped to a in-process SQLite instance and read rights for that collection already given).

### 1. Create an API session


```python
import pandas as pd

from weaveapi.records import *
from weaveapi.options import *
from weaveapi.filter import *
from weaveapi.weaveh import *

WEAVE_CONFIG = "config/demo_client_local.config"
nodeApi, session = connect_weave_api(WEAVE_CONFIG)

scope = "shared"
table = "directory"
```

    {"res":"ok","data":"pong 1674668207181"}


### 2. Create a local table

- we drop the existing table if already existing and re-create it from scratch
- a weavechain node can also connect to existing tables, reading their structure, but in this case we create it via the API


```python
layout = { 
    "columns": { 
        "id": { "type": "LONG", "isIndexed": True, "isUnique": True, "isNullable": False },
        "name_nickname": { "type": "STRING" },
        "name_last": { "type": "STRING" },
        "name_first": { "type": "STRING" },
        "birthday": { "type": "STRING" },
        "email_personal": { "type": "STRING" },
        "phone_number": { "type": "STRING" },
        "address_country": { "type": "STRING" },
        "address_summary": { "type": "STRING" },
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

nodeApi.dropTable(session, scope, table).get()
reply = nodeApi.createTable(session, scope, table, CreateOptions(False, False, layout)).get()
print(reply)
```

    {'res': 'ok', 'target': {'operationType': 'CREATE_TABLE', 'organization': 'weavedemo', 'account': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg', 'scope': 'shared', 'table': 'directory'}}


### 3. Mark some fields for erasure

- the purpose is to protect certain fields when shared


```python
reply = nodeApi.getTableDefinition(session, scope, table).get()
#print(reply)
layout = json.loads(reply["data"])["layout"]
layout["columns"]

newLayout = layout.copy()
del newLayout["layout"]
del newLayout["indexes"]
del newLayout["columnNames"]
newLayout["columns"] = { i["columnName"]: i for i in layout["columns"]}

newLayout["columns"]["phone_number"]["readTransform"] = "ERASURE"
newLayout["columns"]["address_summary"]["readTransform"] = "ERASURE"
newLayout["columns"]["ethereum_wallet_address"]["readTransform"] = "ERASURE"
newLayout["columns"]["birthday"]["readTransform"] = "ERASURE"

reply = nodeApi.updateLayout(session, scope, table, newLayout).get()
print(reply)
```

    {'res': 'ok', 'target': {'operationType': 'UPDATE_LAYOUT', 'organization': 'weavedemo', 'account': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg', 'scope': 'shared', 'table': 'directory'}}


### 4. Write a record in the local storage


```python
records = Records(table, [ 
    [ 1, 'Nickname', 'Last Name', 'First name', '1980-01-01', 'email@gmail.com', '+40712345678', 'US', 'Secret', 'EST', 'https://www.linkedin.com/in/linkedin/', 'discord#1234', '@telegram', '0xwallet' ]
])
reply = nodeApi.write(session, scope, records, WRITE_DEFAULT).get()
print(reply)
```

    {'res': 'ok', 'target': {'operationType': 'WRITE', 'organization': 'weavedemo', 'account': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg', 'scope': 'shared', 'table': 'directory'}, 'data': 'weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg,USr/yA9isOGMQ3/gNenSpZLi2VhwIP9x6UacGTkuBVc=,4YjeYJpUrcrpCf4oTEvuAspeJYiQYEy1AvTgbLsTo8UNzYbHKbNiV6jZihb7si5yc8MbXcr16kmGrieJgNW8s75e'}


### 5. Read the local record, from the local storage

- since we read with the owner key and from the local node, we expect the records to have all fields visible


```python
scope = "shared"
table = "directory"

reply = nodeApi.read(session, scope, table, None, READ_DEFAULT_NO_CHAIN).get()
#print(reply)
df = pd.DataFrame(reply["data"])

df.head()
```




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
      <th>name_nickname</th>
      <th>name_last</th>
      <th>name_first</th>
      <th>birthday</th>
      <th>email_personal</th>
      <th>phone_number</th>
      <th>address_country</th>
      <th>address_summary</th>
      <th>address_timezone</th>
      <th>linkedin_url</th>
      <th>discord_username</th>
      <th>telegram_username</th>
      <th>ethereum_wallet_address</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>Nickname</td>
      <td>Last Name</td>
      <td>First name</td>
      <td>1980-01-01</td>
      <td>email@gmail.com</td>
      <td>+40712345678</td>
      <td>US</td>
      <td>Secret</td>
      <td>EST</td>
      <td>https://www.linkedin.com/in/linkedin/</td>
      <td>discord#1234</td>
      <td>@telegram</td>
      <td>0xwallet</td>
    </tr>
  </tbody>
</table>
</div>



### 5. Connect to proxy server


```python
WEAVE_CONFIG_REMOTE = "config/demo_client_remote.config"
nodeApi2, session2 = connect_weave_api(WEAVE_CONFIG_REMOTE)
```

    {"res":"ok","data":"pong 1674668209764"}


### 6. Read all shared records

- we expect the records that we don't own to have certain fields erased for privacy


```python
scope = "shared"
table = "directory"

reply = nodeApi2.read(session2, scope, table, None, READ_DEFAULT_MUX_NO_CHAIN).get()
#print(reply)
df = pd.DataFrame(reply["data"].get("result"))

df.head()
```




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
      <th>name_nickname</th>
      <th>name_last</th>
      <th>name_first</th>
      <th>birthday</th>
      <th>email_personal</th>
      <th>phone_number</th>
      <th>address_country</th>
      <th>address_summary</th>
      <th>address_timezone</th>
      <th>linkedin_url</th>
      <th>discord_username</th>
      <th>telegram_username</th>
      <th>ethereum_wallet_address</th>
      <th>_nodeKey</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1.0</td>
      <td>Nickname</td>
      <td>Last Name</td>
      <td>First name</td>
      <td></td>
      <td>email@gmail.com</td>
      <td></td>
      <td>US</td>
      <td></td>
      <td>EST</td>
      <td>https://www.linkedin.com/in/linkedin/</td>
      <td>discord#1234</td>
      <td>@telegram</td>
      <td></td>
      <td>weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg</td>
    </tr>
  </tbody>
</table>
</div>



### 7. Check the local node for all operations on the shared data


```python
reply = nodeApi.history(session, scope, table, None, HISTORY_DEFAULT).get()
#print(reply)
df = pd.DataFrame(reply["data"]).transpose()
#display(df)
pd.DataFrame(df.iloc[0]["history"])
```




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
      <th>account</th>
      <th>operation</th>
      <th>timestamp</th>
      <th>ip</th>
      <th>apiKey</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg</td>
      <td>write</td>
      <td>1674668207300999936</td>
      <td>127.0.0.1</td>
      <td>d2f86331322b497fb644e09862b681fdc2a9aa5180d0011c</td>
    </tr>
    <tr>
      <th>1</th>
      <td>weaveyh5R1ytoUCZnr3JjqMDfhUrXwqWC2EWnZX3q7krKLPcg</td>
      <td>read</td>
      <td>1674668207315000064</td>
      <td>127.0.0.1</td>
      <td>d2f86331322b497fb644e09862b681fdc2a9aa5180d0011c</td>
    </tr>
    <tr>
      <th>2</th>
      <td>weavexUTKAe7J5faqmiq94DXXWntyRBA8bPwmrUbCtebxWd3f</td>
      <td>read</td>
      <td>1674668211353999872</td>
      <td>34.28.85.136</td>
      <td>1e2f9e5e7c9f406081256bf5709dd1eae5ccf2e324469e1c</td>
    </tr>
  </tbody>
</table>
</div>
