#!/usr/bin/env python

import sys
import yaml
import xmlrpclib
from lava_tool.authtoken import AuthenticatingServerProxy, KeyringAuthBackend

# lava-tool auth-add https://yongqin.liu@validation.linaro.org/RPC2/

TOKEN = ""
SERVER_URL="https://yongqin.liu:%s@lkft.validation.linaro.org/RPC2/" % TOKEN

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
