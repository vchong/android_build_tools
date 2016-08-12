#!/bin/bash
dir_aosp_master="/home/yongqin.liu/aosp-master"
function change_log(){
	export old_tag="$1"
	export new_tag="$2"
	if [ -z "${old_tag}" ] || [ -z "${new_tag}" ]; then
		return
	fi
	changelog_file="ChangeLog-${old_tag}-${new_tag}-$(date +%Y-%m-%d-%H-%M-%S).txt"
	cd ${dir_aosp_master}
	repo init -b ${new_tag}
	repo sync -j4
	repo forall -c ' \
	        diff_commits=$(git log --oneline --no-merges ${old_tag}..${new_tag} 2>/dev/null|wc -l)
	        if [ ${diff_commits} -gt 0 ]; then \
		    echo ========${REPO_PROJECT} between ${old_tag}..${new_tag}=========
                    git diff --stat ${old_tag} ${new_tag}
                    git log --oneline --no-merges ${old_tag}..${new_tag} 2>/dev/null
		    echo ""
		fi;
               '|tee ${changelog_file}

	total_line=$(grep -e 'file changed' -e "files changed" ${changelog_file}|awk 'BEGIN { file_changed=0; insertions=0; deletions=0} { file_changed=file_changed+$1; insertions=insertions+$4; deletions=deletions+$6} END { printf("%d file changed, %d insertions(+), %d deletions(-)\n", file_changed, insertions, deletions)}')
	echo "*******************************************************"
	echo "*******************************************************"
	echo "    ${total_line}"
	echo "*******************************************************"
	echo "*******************************************************"
	#scp ${changelog_file} people:/home/yongqin.liu/public_html/ChangeLogs
}

change_log android-6.0.1_r46 android-6.0.1_r55
#change_log android-6.0.1_r52 android-6.0.1_r55
#change_log android-6.0.1_r52 android-6.0.1_r54
#change_log android-6.0.1_r25 android-6.0.1_r26
#change_log android-6.0.1_r25 android-6.0.1_r45
#change_log android-6.0.1_r26 android-6.0.1_r45
#change_log android-6.0.1_r45 android-6.0.1_r46
