#!/usr/bin/python
import sys
from subprocess import Popen, PIPE
from subprocess import call

vm_name = sys.argv[1]
container_id = sys.argv[2]

p = Popen(['docker-machine', 'ip', vm_name], stdin=PIPE, stdout=PIPE, stderr=PIPE)
vm_ip, err = p.communicate()
rc = p.returncode

p = Popen(['docker', 'port', container_id], stdin=PIPE, stdout=PIPE, stderr=PIPE)
output, err = p.communicate()
rc = p.returncode

def run(command):
  print command
  call(command.split(' '))

for line in output.split('\n'):
  if len(line) > 0:
    container_port = line.split('/')[0]
    vm_port = line.split(':')[1]
    run('VBoxManage controlvm '+vm_name+' natpf1 delete tcp'+container_port)
    run('VBoxManage controlvm '+vm_name+' natpf1 tcp'+container_port+',tcp,127.0.0.1,'+container_port+',,'+vm_port)
