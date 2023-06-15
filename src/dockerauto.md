# Docker Installation


## Notes

We’ll reference variables using brackets and highlighting, ex. [WEV Dir]

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


## Download Helper Scripts

Download [Install Script] and put it in [WEVDir]

[Install Script] is [install.bat](https://drive.google.com/file/d/17xe8bqXzpRqOKabzv41exizFj70yjk53/view?usp=sharing) for Windows and [install.sh](https://drive.google.com/file/d/14SpEAKyiFE1h55eCmT6usvaKNWcL1N-k/view?usp=sharing) for Linux or Mac

On MacOS or Linux, make sure the downloaded file has proper line endings:

    dos2unix install.sh


Open a terminal, and navigate to [WEVDir]

	cd '[WEVDir]'
	
Note, Mac/Linux users may need to run the following command to adjust permissions

    chmod a+x install.sh

Execute [Install Script], which will install Weavechain and start the next step

    install.bat
    
or

    ./install.sh
