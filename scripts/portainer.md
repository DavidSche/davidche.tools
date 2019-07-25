We do not currently have a guide on how to build Portainer for different OS. However you can download and run one of our prebuilt binaries following the instructions here:
https://portainer.readthedocs.io/en/stable/deployment.html#deploy-portainer-without-docker

You can also build your own binary:
NOTE: This requires Portainer dependencies to be installed and configured correctly. You can find more about how to do this here: https://portainer.gitbook.io/portainer/contributing-to-portainer/contributing-to-the-portainer-project

Navigate to the src/github.com directory in your go workspace: cd $HOME/go/src/github.com
Clone the portainer github repo git clone https://github.com/portainer/portainer.git
Navigate to the directory of the go files to build the binary from: cd portainer/api/cmd/portainer
Build the portainer binary for arm: GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a --installsuffix cgo --ldflags '-s'
You will then have a Portainer binary built in this same directory that you can use. To run your binary, follow the instructions in the portainer.readthedocs.io link at the start of this comment.



Contribute
Use the following instructions and guidelines to contribute to the Portainer project.

Build Portainer locally
Requirements
Ensure you have Docker, Node.js >= 6, yarn and Golang (>= 1.11) installed on your system.

Build
Checkout the project, set up the project inside your $GOPATH and go inside the root directory:

$ git clone https://github.com/portainer/portainer.git
$ mkdir -p ${GOPATH}/src/github.com/portainer
$ ln -s ${PWD}/portainer ${GOPATH}/src/github.com/portainer/portainer
$ cd portainer
Install dependencies with yarn:

$ yarn
Build and run the project:

$ yarn start
Access Portainer at http://localhost:9000

Tip

The frontend application will be updated when you save your changes to any of the sources (app/**/*.js, assets/css/app.css or index.html). Just refresh the browser.

Contribution guidelines
Please follow the contribution guidelines on the repository.

Contributing to the documentation
Checkout the project and go inside the root directory:

$ git clone https://github.com/portainer/portainer-docs.git
$ cd portainer-docs
Update the documentation and trigger a local build:

$ docker run --rm -v ${PWD}/docs:/src portainer/docbuilder:latest make html
This will create a local folder docs/build/html where you will find the generated static files for the documentation.



Contributing to the Portainer Project

How to setup the development environment
Make sure you have installed the dependencies for this project on your Mac or Linux machine before continuing this tutorial. 
Note: Windows is currently not supported by the Portainer development environment.

Instructions:

Step 1: Navigate to the folder you wish to store the code for the Portainer project. This can be anywhere such as on your desktop or in your downloads folder.

Step 2: Download the Portainer project:

git clone https://github.com/portainer/portainer.git
Step 3: Set up a directory to use for local development inside your$GOPATH:

mkdir -p ${GOPATH}/src/github.com/portainer
Step 4: Create a symlink between the project directory inside $GOPATH/ and the Portainer project you downloaded in step 2:

ln -s ${PWD}/portainer/api ${GOPATH}/src/github.com/portainer/portainer
Step 5: Navigate into the Portainer project you downloaded:

cd portainer
Step 6: Install the project dependencies:

yarn
Step 7: Build and run the project:

yarn start
You should now be able to access Portainer at http://localhost:9000​

Tip: The frontend application will be updated when you save your changes to any of the sources (app/**/*.js, assets/css/app.css or index.html). Just refresh the browser :)

Contribution Guidelines
Please follow the contribution guidelines on the repository when contributing to the Portainer codebase or documentation.

Contributing to Our Documentation
If you wish to contribute to the documentation for Portainer, follow the below tutorial to get started.

Step 1: Download the project and navigate inside the project folder:

git clone https://github.com/portainer/portainer-docs.git
cd portainer-docs
Step 2: Edit the documentation, save your files and then enter the following command to trigger a local build:

docker run --rm -v ${PWD}/docs:/src portainer/docbuilder:latest make html
This will create a local folder docs/build/html where you will find the generated static files for the documentation.

​docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer


