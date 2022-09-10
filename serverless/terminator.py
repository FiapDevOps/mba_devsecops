import sys
import time
from boto.ec2.connection import EC2Connection

def main():
    conn = EC2Connection('', '')
    instances = conn.get_all_instances()
    print instances
    for reserv in instances:
        for inst in reserv.instances:
            if inst.state == u'running':
                print "Terminating instance %s" % inst
                inst.stop()

if __name__ == "__main__":
    main()
