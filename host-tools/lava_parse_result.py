#!/usr/bin/python

import csv
import json
import re

from lava_tool.authtoken import AuthenticatingServerProxy, KeyringAuthBackend

## Filter the result with awk
## awk -F ,  '{ if (($4 + 0 >50) || ($4 + 0 <-50)){print $0;} }' host-tools/x15-result.csv

time_mem_units = [ "miliseconds", "ms", "ns", "s", "seconds", "kb"]

#lava-tool job-details https://yongqin.liu@validation.linaro.org/RPC2/ 1504212
# https://validation.linaro.org/scheduler/device_type/hi6220-hikey?dt_length=100&dt_search=android-lcr-reference-hikey-n-117#dt_
#grep -v Complete /tmp/jobs.txt|grep -v Incomplete|grep -v Canceled |tr -d ' \t'|while read -r id; do echo -n "\"$id\", "; done; echo ""
hikey_build1_job_ids = [ "1504606", "1503319", "1503316", "1503087", "1503085", "1502985", "1502983", "1502885", "1502883", "1502603", "1502601", "1502599", "1502597", "1502432", "1502430", "1502428", "1502426", "1502424", "1502422", "1502101", "1501943", "1501941", "1501600", "1501599", "1501597", "1501595", "1501593", "1501591", "1501589", "1501587", "1501585", "1501583", "1501581", "1501579", "1501577", "1501575", "1501573", "1501571", "1501568", "1501566", "1501564", "1501562", "1501560", "1501558", "1501556", "1501554", "1501552", "1501550", "1501548", "1501546", "1501545"]

# https://validation.linaro.org/scheduler/device_type/hi6220-hikey?dt_length=100&dt_search=android-lcr-member-hikey-n-premerge-ci-159#dt_
# jobs for android-lcr-member-hikey-n-premerge-ci-159
hikey_build2_job_ids = [ "1504212", "1505519", "1505517", "1504908", "1504907", "1504905",
                   "1504903", "1504901", "1504899", "1504897", "1504895", "1504893",
                   "1504891", "1504889", "1504887", "1504885", "1504883", "1504881",
                   "1504879", "1504104", "1504102", "1504100", "1504098", "1504096",
                   "1504093", "1504091", "1504089", "1504087", "1504085", "1504083",
                   "1504082", "1504105"]

# https://validation.linaro.org/scheduler/device_type/x15?dt_length=100&dt_search=android-lcr-reference-x15-n-95
x15_build1_job_ids = [ "1502584", "1501715", "1501714", "1501712", "1501710", "1501708", "1501706", "1501704", "1501702", "1501700", "1501698", "1501696", "1501694", "1501692", "1501690", "1501688", "1501686", "1501684", "1501682", "1501680", "1501678", "1501676", "1501674", "1501672", "1501670", "1501668", "1501666", "1501665" ]

# https://validation.linaro.org/scheduler/device_type/x15?dt_length=100&dt_search=android-lcr-member-x15-n-premerge-ci-153
x15_build2_job_ids = ["1504877", "1504876", "1504874", "1504872", "1504870", "1504868", "1504866", "1504864", "1504862", "1504860", "1504858", "1504856", "1504854", "1504852", "1504850", "1504848", "1504846", "1504844", "1504842", "1504840", "1504838", "1504836", "1504834", "1504832", "1504830", "1504079", "1504078" ]


lava_server_url = "https://yongqin.liu@validation.linaro.org/RPC2/"
server = AuthenticatingServerProxy(lava_server_url, auth_backend=KeyringAuthBackend())
badchars = "[^a-zA-Z0-9\._-]"


#server.dashboard.get("ced91695e2e2cbb8984a8d93ff4d638410b44f2a")
def getBundleIdWithJobId(job_id=None):
    if job_id is None or job_id == "":
        return None

    job_details = server.scheduler.job_details(job_id)
    job_status = job_details.get("status")
    if job_status != "Complete":
        #print "status:%s "% job_details.get("status")
        return None
    results_bundle = job_details.get("_results_link")
    if results_bundle is None:
        sub_id = job_details.get("sub_id")
        if sub_id is None or sub_id == "":
            return None
        else:
            host_id = sub_id.replace(".1", ".0")
            return getBundleIdWithJobId(job_id=host_id )
    else:
        bundle_id = results_bundle.strip("/").split("/")[-1]
        return bundle_id


test_ids_ignored = [ "lava",
                     "multinode-target" ]
sub_cases_ids_ignored = [ "lava-test-shell-run",
                          "BOOTTIME_LOGCAT_ALL_COLLECT",
                          "BOOTTIME_LOGCAT_EVENTS_COLLECT",
                          "BOOTTIME_DMESG_COLLECT",
                          "BOOTTIME_ANALYZE",
                          "SERVICE_STARTED_ONCE",
                          "start_bootchart",
                          "enabled_bootchart",
                          "stop_bootchart",
                          "rm_start_file",
                          "bootchart_collect_data",
                          "bootchart_parse",
                          "CTS-Command-Check",
                          "optee-xtest-run",
                          "xtest-subtests-fail-rate",
                          "xtest-subtests-passes",
                          "xtest-subtests-fails",
                          "xtest-tests-fail-rate",
                          "xtest-tests-fails",
                          "xtest-tests-skipped",
                          "lava-test-shell-install" ]

def getResultFromBundleOfOneJob(bundle=None):
    if bundle is None or bundle.get("test_runs") is None:
        return None

    results_all = {}
    test_runs = bundle.get("test_runs")
    for test in test_runs:
        test_id = test.get('test_id').replace(" ", "_")
        if test_id in test_ids_ignored:
            continue
        test_id = re.sub(badchars, "_", test_id)
        test_results = test.get("test_results")
        for test_result in test_results:
            sub_case_id = test_result.get("test_case_id")
            sub_case_id = re.sub(badchars, "_", sub_case_id)
            if sub_case_id in sub_cases_ids_ignored:
                continue

            if sub_case_id.endswith("_sigma") or sub_case_id.endswith("_std_err"):
                continue

            if test_id == "cts-host" and (sub_case_id.endswith("_executed") or sub_case_id.endswith("_failed")):
                continue

            if sub_case_id.startswith("tj32_"):
                sub_case_id = sub_case_id.replace("tj32_", "32_", 1)

            if sub_case_id.startswith("tj64_"):
                sub_case_id = sub_case_id.replace("tj64_", "64_", 1)

            if sub_case_id.startswith("tjbench32_"):
                sub_case_id = sub_case_id.replace("tjbench32_", "32_", 1)

            if sub_case_id.startswith("tjbench64_"):
                sub_case_id = sub_case_id.replace("tjbench64_", "64_", 1)

            result = test_result.get("result")
            measurement = test_result.get("measurement")
            units = test_result.get("units")
            test_ids_no_prefix = [ "cts-host", "lava-android-benchmark-host"]
            if test_id in test_ids_no_prefix:
                full_test_name = sub_case_id
            else:
                full_test_name = "%s#%s" % (test_id, sub_case_id)

            results_all[full_test_name] = { "result": result,
                                            "measurement": measurement,
                                            "units": units
                                           }

    return results_all


def mergeResult(totalResult={}, subResult={}):
    for full_test_name in subResult:
        if totalResult.get(full_test_name) is not None:
            old_result = totalResult.get(full_test_name)
            new_result = subResult.get(full_test_name)
            if old_result.get("result") != "pass" and new_result.get("result") == "pass":
                old_result["result"] = "pass"
            if new_result.get("measurement") is not None:
                units = new_result.get("units")
                measurement = new_result.get("measurement")
                if units is not None and units.lower() in time_mem_units:
                    if float(measurement) <= float(old_result.get("measurement")):
                        old_result["measurement"] = measurement
                else:
                    if float(measurement) >= float(old_result.get("measurement")):
                        old_result["measurement"] = measurement
        else:
            totalResult[full_test_name] = subResult[full_test_name]


def getResultForBuild(job_ids=None):
    if job_ids is None or len(job_ids) == 0:
        return None
    results_all = {}
    for job_id in job_ids:
        bundle_id = getBundleIdWithJobId(job_id)
        if bundle_id is None:
            continue
        else:
            print "Trying to get result for job(id=%s), bundle(id=%s)" % (job_id, bundle_id)
            try:
                response = server.dashboard.get(bundle_id)
                results_job = getResultFromBundleOfOneJob(bundle=json.loads(response["content"]))
                mergeResult(totalResult=results_all, subResult=results_job)
            except Exception as e:
                raise RuntimeError("job_id=%s, bundle_id=%s e=%s" % (job_id, bundle_id, e))

    return results_all


def compareFor2Builds(build1_job_ids=[], build2_job_ids=[], result_csv=None):
    print "=======getting result for build1======"
    build1_results = getResultForBuild(build1_job_ids)
    print "=======getting result for build2======"
    build2_results = getResultForBuild(build2_job_ids)
    all_keys = []
    for key in build1_results.keys():
        if key not in all_keys:
            all_keys.append(key)
    for key in build2_results.keys():
        if key not in all_keys:
            all_keys.append(key)
    all_keys.sort()
    print "=======output compare result======"
    compare_result = []
    for key in all_keys:
        test_name = key
        build1_test = build1_results.get(test_name)
        build2_test = build2_results.get(test_name)
        if build1_test is None:
            build1_str = "--"
        elif build1_test.get("measurement") is not None:
            build1_str = build1_test.get("measurement")
        else:
            build1_str = build1_test.get("result")

        if build2_test is None:
            build2_str = "--"
        elif build2_test.get("measurement") is not None:
            build2_str = build2_test.get("measurement")
        else:
            build2_str = build2_test.get("result")

        difference = 0
        if ( build2_test is None and build1_test is not None ):
            difference = -100
        elif (build2_test is not None and build1_test is None ):
            difference = 100
        elif build2_test is None and build1_test is None:
            difference = 0
        elif build2_test.get("result") != build1_test.get("result"):
            if build2_test.get("result").lower() == "pass":
                difference=100
            elif build1_test.get("result").lower() == "pass":
                difference = -100
            else:
                difference = -100
        elif build2_test.get("measurement") is not None and build1_test.get("measurement") is None:
            difference = 100
        elif build2_test.get("measurement") is None and build1_test.get("measurement") is not None:
            difference = 100
        elif build2_test.get("measurement") is not None and build1_test.get("measurement") is not None:
            try:
                build2_measurement = float(build2_test.get("measurement"))
                build1_measurement = float(build1_test.get("measurement"))
                if build2_measurement == 0 and build1_measurement == 0:
                    difference = 0
                elif build1_measurement == 0:
                    difference = 100
                else:
                    difference = (build2_measurement - build1_measurement) * 100 / build1_measurement
            except ValueError as e:
                print "build2_test.get(\"measurement\")=%s, build1_test.get(\"measurement\")=%s" %(build2_test.get("measurement"), build1_test.get("measurement"))
                difference = 100
        else:
            # both measurement is None, then use the difference from result comparison
            pass

        units = build1_test.get("units")
        if units is None:
            units = build2_test.get("units")

        if units in time_mem_units:
            difference = (-1) * difference

        print "%s %s %s %s" %(test_name, build1_str, build2_str, difference)
        if result_csv is not None:
            compare_result.append([test_name, build1_str, build2_str, difference])

    if result_csv is not None:
        with open(result_csv, 'wb') as f:
            writer = csv.writer(f)
            writer.writerows(compare_result)


def main():
    print "Start to compare for hikey builds"
    compareFor2Builds(build1_job_ids=hikey_build1_job_ids, build2_job_ids=hikey_build2_job_ids, result_csv="hikey-result.csv")
    print "Start to compare for x15 builds"
    compareFor2Builds(build1_job_ids=x15_build1_job_ids, build2_job_ids=x15_build2_job_ids, result_csv="x15-result.csv")

if __name__ == '__main__':
    main()
