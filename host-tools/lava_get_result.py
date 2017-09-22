#!/usr/bin/env python

import re
import sys
import yaml
import xmlrpclib
from lava_tool.authtoken import AuthenticatingServerProxy, KeyringAuthBackend

# lava-tool auth-add https://yongqin.liu@validation.linaro.org/RPC2/

TOKEN = ""
SERVER_URL="https://yongqin.liu:%s@staging.validation.linaro.org/RPC2/" % TOKEN

pat_ignore = re.compile(".*("
                        "-stderr"
                        "|-sigma"
                        "|-max"
                        "|-min"
                        "|-itr\d+"
                        "|regression_\d+"
                        "|arm64-v8a.+_executed"
                        "|arm64-v8a.+_failed"
                        "|armeabi-v7a.+_executed"
                        "|armeabi-v7a.+_failed"
                        ")$")
names_ignore = ["test-attachment",
                "test-skipped", "regression_4003_XTS", "regression_4003_NO_XTS", "subtests-fail-rate",
                "tradefed-test-run",
               ]

server = AuthenticatingServerProxy(SERVER_URL, auth_backend=KeyringAuthBackend())
#TOKEN = "n2ab47pbfbu4um0sw5r3zd22q1zdorj7nlnj3qaaaqwdfigahkn6j1kp0ze49jjir84cud7dq4kezhms0jrwy14k1m609e8q50kxmgn9je3zlum0yrlr0njxc87bpss9"
#SERVER_URL="https://yongqin.liu:%s@validation.linaro.org/RPC2/" % TOKEN

def get_yaml_result(job_id, server):
    tests_res = []
    # server = xmlrpclib.ServerProxy(SERVER_URL)
    try:
        #job_id = server.scheduler.submit_job(job_yaml_str)
        res = server.results.get_testjob_results_yaml(job_id)
        #res = server.results.get_testjob_results_csv(job_id)
        #print "results for job %s:" % str(job_id)
        #print "%s" % str(yaml.load(res))
        for test in yaml.load(res):
            if test.get("suite") == "lava":
                continue
            if pat_ignore.match(test.get("name")):
                continue

            if test.get("name") in names_ignore:
                continue
            ## print "%s" % str(test)
            tests_res.append(test)

        return tests_res

    except xmlrpclib.Fault as e:
        raise e
    except:
        raise


def main():
#    if len(sys.argv) < 3:
#        print ("""usage: submit_job.py JOB_YAML SERVER_URL""")
#        exit(1)
#    job_ids = ["187866", "187865",
#               "187864", "187863", "187862", "187861", "187860",
#               "187859", "187858", "187857", "187856", "187855",
#               "187854", "187853", "187852", "187851", "187850",
#               "187849", "187848", "187847", "187846", "187845",
#               "187844", "187843", "187842", "187841",]

    jobs_failed = []
    total_tests_res = []
#    job_ids = ["187841", "187842"]
    jobs = server.results.make_custom_query("testjob",
                                            "description__icontains__android-lcr-reference-hikey-o-10")
#    for job in jobs:
    #print str(jobs)
    #sys.exit(0)
#        print "%s %s %s" % (job.get("id"), job.get("description"), job.get("status"))
        #print str(job)
    #main()
    for job in jobs:
        job_id = job.get("id")
        tests_res = get_yaml_result(job_id, server)
        if len(tests_res) == 0:
            jobs_failed.append(job_id)
        else:
            total_tests_res.extend(tests_res)

    for test in total_tests_res:
        print str(test)
        #print "%s %s %s %s" % (test.get("name"), test.get("result"), test.get("measurement"), test.get("unit"))

    print "Failed Jobs/All Jobs: %d/%d" %(len(jobs_failed), len(jobs))
    for job_id in jobs_failed:
        job_details = server.scheduler.job_details(job_id)
        print "Failed job: %s : %s : %s" % (job_id, job_details.get("description"), job_details.get("status"))

if __name__ == "__main__":
    main()
