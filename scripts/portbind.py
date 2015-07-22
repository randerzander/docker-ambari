import sys
from subprocess import Popen, PIPE
from subprocess import call

container_id = sys.argv[1]

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
    run('VBoxManage controlvm boot2docker-vm natpf1 delete tcp'+container_port)
    run('VBoxManage controlvm boot2docker-vm natpf1 tcp'+container_port+',tcp,,'+container_port+',,'+vm_port)
