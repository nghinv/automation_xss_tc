#!/bin/bash -xv
if [[ -z $1 || "x$1" == "x" ]]; then
  echo "`date`, going to run test on all the modules"
else
  echo "`date`, going to run test on module: $1"
fi

TEST_MODULE=${1:-"./"}
TEST_TARGET_OPTION=${TEST_TARGET_OPTION:-"http://localhost:8080"}
TEST_BROWSER_OPTION=${TEST_BROWSER_OPTION:-"*firefox /usr/lib/firefox/firefox-bin"}
TEST_SELENIUM_VERSION_OPTION=${TEST_SELENIUM_VERSION_OPTION:-"selenium-server-standalone-2.25.0.jar"}

automation_project_dir="/java/exo-working/automation_xss_tc/plf4.0.x/"
if [ ! -d ${automation_project_dir} ]; then
  echo "`date`,ERROR:: folder ${automation_project_dir} does not exist, exit!"
fi
# prepare test folder
test_time_stamp=`date +%y%m%d_%H%M%S`
test_result_dir="${automation_project_dir}/TESTS/test_results_${test_time_stamp}"
mkdir -p "${test_result_dir}"
rm -f latestresult
ln -s ${test_result_dir} latestresult

cp ${automation_project_dir}/COMMON/COMM_*.html ${test_result_dir}
rm -f RESUL_SUITE_*.html
rm -f SUITE_*.html

cp ${automation_project_dir}/COMMON/tqa-secu-user-extensions.js ${test_result_dir}/user-extensions.js
cp ${automation_project_dir}/COMMON/*.jar ${test_result_dir}
find ${automation_project_dir}/${TEST_MODULE}/* -type f | grep -v -E "(^SUITE|/SUITE|COMMON|TESTS/)" | grep -E "(^|/)XSS_(STOR|REFL).*html$" | xargs -I {} cp {} ${test_result_dir}

pushd ${test_result_dir}

test_definition_table="</tbody></table>"
suite_template="../../COMMON/SUITE_COMM_suite_template.html"
test_result_template="../../COMMON/SUITE_COMM_result_template.html"
test_result_file="TEST_RESULT_REPORT_${test_time_stamp}.html"
suite_template_title="Test Suite Template"


cp ${test_result_template} ${test_result_file}
sed -i "s/on DATE/on ${test_time_stamp}/g" ${test_result_file}
  
echo "`date`,INFO:: build test suites and test result table"
not_run_count=0

# pretest script
echo "`date`,INFO:: doing pretests"
testscript=COMM_pretest.html
echo "`date`, INFO:: testscript=${testscript} "
testscript=`echo ${testscript} | sed -r 's#\.html$##g'`
test_definition="<tr><td><a href=\"${testscript}.html\">${testscript}</a></td></tr>"
testsuite=PRETEST_SUITE_${testscript}.html
cp ${suite_template} ${testsuite}
sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" ${testsuite}
sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" ${testsuite}
sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" ${testsuite}
#sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" ${testsuite}
#sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" ${testsuite}

java -jar ${TEST_SELENIUM_VERSION_OPTION} -ensureCleanSession -userExtensions user-extensions.js -htmlSuite "${TEST_BROWSER_OPTION}" "${TEST_TARGET_OPTION}/" "./${testsuite}" "./RESULT_${testsuite}"

for testscript in `find * -type f | grep -v -E "(^SUITE_|^COMM_)" | grep -E "(^|/)XSS_(STOR|REFL).*html$"`; do
  echo "`date`, INFO:: testscript=${testscript} "
  testscript=`echo ${testscript} | sed -r 's#\.html$##g'`
  test_definition="<tr><td><a href=\"${testscript}.html\">${testscript}</a></td></tr>"
  cp ${suite_template} SUITE_${testscript}.html
  sed -i "s#${test_definition_table}#${test_definition}\n${test_definition_table}#g" SUITE_${testscript}.html
  sed -i "s#${test_definition_table}#<tr class=\"status_not_run\"><td><a href=\"\#\" onclick=\"show_detail('RESULT_SUITE_${testscript}.html')\">RESULT_SUITE_${testscript}</a></td><td>SUITE_${testscript}_NOT_RUN_YET</td><result></tr>${test_definition_table}#g" ${test_result_file}
  sed -i "s#${test_definition_table}#\n${test_definition_table}#g" ${test_result_file}
  not_run_count=$((not_run_count+1))
done

echo "`date`,INFO:: start testing"
init_element=0
passed_count=0
failed_count=0
total_count=${not_run_count}
row_total="<tr class=\"status_total\"><td><b>Total:</b></td><td><b>"
row_close="</b></td></tr>"
row_failed="<tr class=\"status_failed\"><td><b>Failed:</b></td><td><b>"
row_passed="<tr class=\"status_passed\"><td><b>Passed:</b></td><td><b>"
row_notrun="<tr class=\"status_not_run\"><td><b>Not run yet:</b><td><b>"

sed -i "s#${row_total}#${row_total}${total_count}${row_close}#g" ${test_result_file}
sed -i "s#${row_notrun}.*${row_close}#${row_notrun}${not_run_count}${row_close}#g" ${test_result_file}

for testsuite in `find SUITE_* -type f | grep -E "html$"`; do
   echo "`date`, >>> processing $testsuite "
   if [ ! ${init_element} -gt 0 ]; then
     init_element=1
     sed -i "s/input type=\"hidden\" id=\"init_element\" value=\"#\"/input type=\"hidden\" id=\"init_element\" value=\"RESULT_${testsuite}\"/g" ${test_result_file}
   fi

   java -jar ${TEST_SELENIUM_VERSION_OPTION} -ensureCleanSession -userExtensions user-extensions.js -htmlSuite "${TEST_BROWSER_OPTION}" "${TEST_TARGET_OPTION}/" "./${testsuite}" "./RESULT_${testsuite}"
   sed -i "s/Test suite results/Test suite results for ${testsuite}/g" RESULT_${testsuite}
   RESULT_MSG="NOT_RUN_YET"
   RESULT_MSG_CLASS="status_not_run"
   test_result_failed=`grep -A 1 -B 3 -F "<td>result:</td>" ./RESULT_${testsuite} | grep -c -F "<td>failed</td>"`
   if [ ${test_result_failed} -gt 0 ]; then
    RESULT_MSG="FAILED"
    RESULT_MSG_CLASS="status_failed"
    failed_count=$((failed_count+1))
   fi
   
   test_result_failed=`grep -A 1 -B 3 -F "<td>result:</td>" ./RESULT_${testsuite} | grep -c -F "<td>passed</td>"`
   if [ ${test_result_failed} -gt 0 ]; then
    RESULT_MSG="PASSED"
    RESULT_MSG_CLASS="status_passed"
    passed_count=$((passed_count+1))
   fi
   not_run_count=$((total_count-passed_count-failed_count))
   testscript=`echo ${testsuite} | sed -r 's#\^SUITE_##g'`
   testsuite=`echo ${testsuite} | sed -r 's#\.html$##g'`

   
   sed -i "s#${testsuite}_NOT_RUN_YET#${RESULT_MSG}#g" ${test_result_file}
   sed -i "s#<tr class=\"status_not_run\"><td><a href=\"\#\" onclick=\"show_detail('RESULT_${testsuite}.html#<tr class=\"${RESULT_MSG_CLASS}\" ><td><a href=\"\#\" onclick=\"show_detail('RESULT_${testsuite}.html#g" ${test_result_file}
   sed -i "s#${row_passed}.*${row_close}#${row_passed}${passed_count}${row_close}#g" ${test_result_file}
   sed -i "s#${row_failed}.*${row_close}#${row_failed}${failed_count}${row_close}#g" ${test_result_file}
   sed -i "s#${row_notrun}.*${row_close}#${row_notrun}${not_run_count}${row_close}#g" ${test_result_file}
   gzip ${testscript}
done

gzip user-extensions.js
rm -f selenium-server-standalone*
gzip COMM_*
gzip XSS*
