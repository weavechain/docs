# Docker Installation


## Notes

We’ll reference variables using brackets and highlighting, ex. [WEV Dir]

Commands to be run will be in italics, ex.

	mkdir 'C:\Program Files\Weavechain\weaveconfig'

Note, docker commands run on Mac/Linux may require sudo, depending how docker was installed.


## Prerequisites


### Docker

Macos: [https://docs.docker.com/desktop/mac/install/](https://docs.docker.com/desktop/mac/install/)

Watch out for Chipset. Check in Apple menu -> About this Mac, [screen here](https://drive.google.com/file/d/10kZHu_kVXL7MChi08IxJ0SVPHhCt7scT/view?usp=sharing)

Note: On MacOS, make sure the a file ‘Docker’ has the ‘.dmg’ extension

Windows: [https://docs.docker.com/desktop/windows/install/](https://docs.docker.com/desktop/windows/install/)

Ubuntu/debian: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

Install docker compose (unnecessary on win/mac) [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)

Optional, run sample command to test: docker run -d -p 80:80 docker/getting-started


# Setup Weavechain


## Prepare Directory Structure

Create a directory for all application files which we’ll refer to as [WEV Dir]

Ex. C:\Program Files\Weavechain , or /Applications/Weavechain

Create 2 sub-directories: [WEV Dir]\weaveconfig and [WEV Dir]\weavestorage

	mkdir '[WEV Dir]\weaveconfig'
	mkdir '[WEV Dir]\weavestorage'


## Download the latest version of Weavechain

Open a terminal, and navigate to [WEV Dir]

	cd [WEV Dir]

Let’s define your [WEV Version]

The default is ‘latest’

If you’re using an ARM machine (ex. The new Macbooks), use ‘1.26-arm’

Pull the Weavechain code

	docker pull gcr.io/weavechain/weave_node:[WEV Version]

Ex. 

	docker pull gcr.io/weavechain/weave_node:latest


## Create your account keys and node configurations

The command we’ll run will prompt you for an ID that you’ll use as your account name


	docker run --mount type=bind,src=[WEV Dir]/weaveconfig,dst=/app/config -ti gcr.io/weavechain/weave_node:[WEV Version] /bin/bash bin/node -kf /app/config

The command will return a line with your ID and public key

Provide this to Weavechain for the purposes of our sample Sidechain

   Ex. omare weaveuGMS8GZhHZ5bc57XUaThFXyPMv5WbDF659NEB681kftm


## Start Weavechain node

	docker run -d --mount type=bind,src=[WEV Dir]/weaveconfig,dst=/app/config --mount type=bind,src=[WEV Dir]/weavestorage,dst=/storage --name weave_node -p 0.0.0.0:18080:18080 -p 0.0.0.0:18000:18000 -ti gcr.io/weavechain/weave_node:[WEV Version] /bin/bash bin/node /app/config/demo.config


# Run Jupyter Demo for Testing

This demo has Jupyter, the Weavechain Python API, and Homomorphic Encryption libraries

Note, the ARM version does not support Homomorphic Encryption.


## Download the Jupyter Demo image

Let’s define your [Jupyter Version]

The default is ‘latest’

If you’re using an ARM machine (ex. The new Macbooks), use ‘1.4-arm’

Pull the Jupyter container

	docker pull gcr.io/weavechain/weave_he_jupyter:latest


## Start the Jupyter Demo image

	docker run -d --mount type=bind,src=**[WEV Dir]**/weaveconfig,dst=/app/config --name weave_he_jupyter -p 0.0.0.0:18888:18888 gcr.io/weavechain/weave_he_jupyter[:](http://gcr.io/weavechain/weave_he_jupyter:latest)[Jupyter Version]


## Run the Demo in the Jupyter notebook in the browser

Extract your Jupyter URL+token from the logs

	docker logs weave_he_jupyter

Copy the URL with [http://127.0.0.1:18888](http://127.0.0.1:18888/) in it from the logs and open it in a browser

Click into the config/ folder, and open up demo_client_local.config

Replace the "host" parameter

Use host.docker.internal if on windows

Use your IP on Mac/Linux (run ipconfig getifaddr en0 to get your IP)

Back In the root directory, open demo.ipynb and run each of the 6 steps in the notebook

1. Establish a session, connecting your Jupyter environment to the local node

2. Creating the directory table locally, with some fields hidden

    **NOTE: That flag "readTransform": "ERASURE" is how you preserve privacy**

3. Write your information to your local table via Weavechain

    **NOTE: Replace the placeholder text with your details here**

4. Read your information from your local table (to ensure the write worked)

5. Connect to the Sidechain via the Remote Proxy Node (aka Public Endpoint)

6. Read all available information from the Sidechain, including yours!


# Reference


## Docker Convenience Functions


### Container Management

The [Container]s we work with above are ‘weave_node’ and ‘weave_he_jupyter’

To stop the container,

	docker stop [Container]

_Ex. 

	docker stop weave_he_jupyter

To remove the container and free up memory,

	docker rm [Container]


## Troubleshooting


### Docker Errors


#### “Invalid mount config for type “bind”: bind source path does not exist”

Ensure that you [created all of the correct folders](#bookmark=id.gusx812kwofm) and that your paths are correct

If using Docker Desktop (Mac, Win), you may need to update your File Sharing settings

Settings -> Resources -> File Sharing: Add [WEV Dir] then Apply & Restart


