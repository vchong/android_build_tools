#!/usr/bin/env python

import sys
import yaml
import xmlrpclib
from lava_tool.authtoken import AuthenticatingServerProxy, KeyringAuthBackend

# lava-tool auth-add https://yongqin.liu@validation.linaro.org/RPC2/

#TOKEN = "ty1dprzx7wysqrqmzuytccufwbyyl9xthwowgim0p0z5hm00t6mzwebyp4dgagmyg2f1kag9ln0s9dh212s3wdaxhasm0df7bqnumrwz1m5mbmf4xg780xgeo9x1348k"
#SERVER_URL="https://yongqin.liu:%s@staging.validation.linaro.org/RPC2/" % TOKEN

TOKEN = "n2ab47pbfbu4um0sw5r3zd22q1zdorj7nlnj3qaaaqwdfigahkn6j1kp0ze49jjir84cud7dq4kezhms0jrwy14k1m609e8q50kxmgn9je3zlum0yrlr0njxc87bpss9"
SERVER_URL="https://yongqin.liu:%s@validation.linaro.org/RPC2/" % TOKEN

def submit_yaml_job(job_yaml_str, server_url):
    # server = xmlrpclib.ServerProxy(SERVER_URL)
    server = AuthenticatingServerProxy(server_url, auth_backend=KeyringAuthBackend())
    try:
        job_id = server.scheduler.submit_job(job_yaml_str)
        print "Job %s submitted successfuly." % str(job_id)
    except xmlrpclib.Fault as e:
        raise e
    except:
        raise


def main():
    if len(sys.argv) < 3:
        print ("""usage: submit_job.py JOB_YAML SERVER_URL""")
        exit(1)

    with open(sys.argv[1], 'r') as stream:
        job_yaml = stream.read()
        submit_yaml_job(job_yaml, sys.argv[2])

if __name__ == "__main__":
    main()
