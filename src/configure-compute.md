# Configure Compute

### Docker

In order to run compute-to-data, you need to configure a service to run the tasks. The easiest to configure is a docker server.

- if running in a docker container, make sure it's present or add a compute section in the node config:
 
```json
  'compute': {
    'dockerServiceURL': 'http://host.docker.internal:2375',
    'keyStore': 'keystore.jks',
    'keyStorePass': 'password'
  },
```

- if running as a standalone service
```json
  'compute': {
    'dockerServiceURL': 'http://host.docker.internal:2375',
    'keyStore': 'keystore.jks',
    'keyStorePass': 'password'
  },
```

- if running the node itself as a docker, replace *localhost* with **host.docker.internal** or the host ip obtained via /sbin/ifconfig or ipconfig 
- *host.docker.internal* works on windows or MacOS, while on Linux the host ip should be used or the docker network interface gateway, which is usually 172.17.0.1, but can differ if there are multiple docker networks
- consider using https and authentication for production


**Linux/MacOS/Windows**:
- run the following command
```sh
  docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 0.0.0.0:2375:2375 bobrik/socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
```

- ARM
- ```sh
  docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 0.0.0.0:2375:2375 alpine/socat@sha256:9e59291bebb792982c7d162fb821f7a46b1a587bc3a585240f813f135ae09b85 TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock
```

**Windows**
- open Docker Desktop
- go to Settings -> General -> enable "Expose daemon on tcp://localhost"
