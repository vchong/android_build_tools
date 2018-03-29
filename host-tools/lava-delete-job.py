#!/usr/bin/python
import xmlrpclib
username = "yongqin.liu"
token = "x2oxjy40y7q7ilqf2siqjm935aqkcdazd543fcpofqj3ex4f7nsuoirr73rojnuxfe5hs7x1wsgr1zdnqdk2sf1q5lhlec78pbeb4hc6eo8tjcfkepamcjgj61h8becy"
hostname = "lkft.validation.linaro.org"  # lkft.validation.linaro.org
server = xmlrpclib.ServerProxy("https://%s:%s@%s/RPC2" % (username, token, hostname))
print(server.system.listMethods())
with open("/tmp/work/queue-id.txt", 'r') as fd:
    job_ids = fd.readlines()
    for job_id in job_ids:
        print "== %s ==" % (job_id.strip())
        server.scheduler.cancel_job(job_id.strip())
