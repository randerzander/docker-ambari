**Note**: The guide below assumes you've already setup Docker in your environment. See [boot2docker](https://docs.docker.com/installation/mac/) install instructions for help.

To build the dev23 container image:
```
docker build -t dev23 .
```

To run the container image once built:
```
# You can remove --privileged if you don't intend to use Kerberos
docker run -d -P -h docker.dev --privileged dev23
```

To start a bash prompt inside the running container:
```
docker ps
randy$> docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS  NAMES
19f4d657579d        dev23:latest        "/scripts/start-serv   14 minutes ago      Up 14 minutes       0.0.0.0:32872->2181/tcp, 0.0.0.0:32860->4040/tcp, 0.0.0.0:32845->6080/tcp, .....
randy$> docker exec -it 19f4 bash
randy$> docker exec -it 19f bash
bash-4.1# 
```

To instruct boot2docker to map all of your container's exposed ports to the same ports on your host machine's localhost:

**Note**:  Expect to see errors for every port the first time you run this. The script is telling VirtualBox to delete port mappings between the boot2docker-vm and localhost, then create a new port-mapping for the new container.
```
python scripts/portbind.py 19f4
VBoxManage controlvm boot2docker-vm natpf1 delete tcp9992
VBoxManage: error: Code NS_ERROR_INVALID_ARG (0x80070057) - Invalid argument value (extended info not available)
VBoxManage: error: Context: "RemoveRedirect(Bstr(a->argv[3]).raw())" at line 523 of file VBoxManageControlVM.cpp
VBoxManage controlvm boot2docker-vm natpf1 tcp9992,tcp,,9992,,32806
VBoxManage controlvm boot2docker-vm natpf1 delete tcp9991
VBoxManage: error: Code NS_ERROR_INVALID_ARG (0x80070057) - Invalid argument value (extended info not available)
VBoxManage: error: Context: "RemoveRedirect(Bstr(a->argv[3]).raw())" at line 523 of file VBoxManageControlVM.cpp
VBoxManage controlvm boot2docker-vm natpf1 tcp9991,tcp,,9991,,32781
```

You should now be able to access Ambari via docker.dev:8080 in your host machine's browser. Most HDP packages are pre-installed via yum, so cluster install time should be short. ambari-agent is already running, so use the manual host-registration radio button instead of keyless ssh. You can ignore the few host-check warnings you see during registration (those are artifacts of host OS-container kernel interaction).

You will want to customise the boot2docker VM settings in ~/.boot2docker/profile. To do so:
```
boot2docker down
boot2docker destroy
boot2docker config > ~/.boot2docker/profile
# Now edit ~/.boot2docker/profile, make your changes and then..
boot2docker init
```

If you have problems using "docker ps", "docker run" with network issues, run "boot2docker ip" and check that the right IP address is specified in ~/.bash_profile. When updating those values, you'll need to force quit terminal and start it again before "docker" CLI commands pick up the new IP address.
