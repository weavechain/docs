# Docker Installation


**Linux/MacOS**

- create and go to a folder where the node data and configs should be kept
```sh
  curl -O https://public.weavechain.com/file/install.sh
  chmod a+x install.sh
  ./install.sh
```

eventually, if you did not configure docker to run by your user (sudo usermod -aG docker $USER), run
```sh
  sudo ./install.sh
```

- subsequent start/stop of the node
```sh
  docker stop weave_node
  docker start weave_node
```

**Windows**

- create and go to a folder where the node data and configs should be kept
- open Docker Desktop, go to Settings -> Resources -> File sharing and add the path to this folder, then Appy & Restart docker
- save [install.bat](https://public.weavechain.com/file/install.bat) in that folder or get it using
```sh
  curl -O https://public.weavechain.com/file/install.bat
```

- run it

- subsequent start/stop of the node
```sh
  docker stop weave_node
  docker start weave_node
```
