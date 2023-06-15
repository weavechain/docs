# Standalone Installation


**Linux/MacOS**

- install java 17 or newer (*brew install java* on MacOS, *sudo apt install openjdk-17-jre* on Debian/Ubuntu, check a how-to for your psecific system)

- extract the weavechain node
```sh
  wget https://public.weavechain.com/file/node-1.39.tar.bz2
  tar -xf node-1.39.tar.bz2
  chmod a+x node-1.39/bin/node
```

- create the folders for config files and storage
```sh
  mkdir config
  mkdir storage
```

- generate a new key pair and demo configs
```sh
  node-1.39/bin/node -kfs config
```

- start the node
```sh
  node-1.39/bin/node config/demo.config
```


**Windows**

- install Chocolatey: https://chocolatey.org/install 
- start a new Powershell with Adminstrator rights
- install wget, bzip2 and Java if not already present
```sh
  choco install wget
  choco install bzip2
  choco install openjdk17
```

- create a new folder for the node and go to it, for example
```sh
  mkdir c:\weavechain
  cd /d c:\weavechain
```

- extract the weavechain node
```sh
  curl -O https://public.weavechain.com/file/node-1.39.tar.bz2
  tar -xf node-1.39.tar.bz2
```

- create the folders for config files and storage
```sh
  mkdir config
  mkdir storage
```

- generate a new key pair and demo configs
```sh
  node-1.39\bin\node.bat -kfs config
```

- start the node
```sh
  node-1.39\bin\node.bat config\demo.config
```
