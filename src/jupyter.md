# Local Jupyter Installation


How to install a local jupyter server docker image preconfigured to easily connect to a local Weavechain node, having the python API and few demo notebooks, as well as pre-built libraries for homomorphic encryption (for x86-64 processors):


**Linux/MacOS**

- create and go to a folder where the node data and configs should be kept
```sh
  curl -O https://public.weavechain.com/file/install_jupyter.sh
  chmod a+x install_jupyter.sh
  ./install_jupyter.sh
```

eventually, if you did not configure docker to run by your user (sudo usermod -aG docker $USER), run
```sh
  sudo ./install_jupyter.sh
```


**Windows**

- save [install_jupyter.bat](https://public.weavechain.com/file/install_jupyter.bat) or get it using
```sh
  curl -O https://public.weavechain.com/file/install_jupyter.bat
```

- run it

- subsequent start/stop of the node
```sh
  docker stop weave_jupyter_public
  docker start weave_jupyter_public
```

**Connecting**

- check the weave_jupyter_public docker image logs, either by opening Docker Desktop (if it's the case) and clicking on its name, or by running
```sh
  docker logs weave_jupyter_public
```
- get the URL with the token shown in the logs. It should look something like http://localhost:18888/?token=1234567890abcdef
- in case of docker restart, the token will change

**Standalone**

For the standalone node installation, [jupyterlab-desktop](https://github.com/jupyterlab/jupyterlab-desktop) can be a convenient choice.