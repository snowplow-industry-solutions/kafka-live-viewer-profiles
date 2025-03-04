#!/usr/bin/env bash
set -eou pipefail
cd $(dirname $0)

default_base_package="com.snowplowanalytics.liveviewerprofile"
test_cases=${test_cases:-"KafkaConsumerServiceIntegrationTest VideoEventRepositoryIntegrationTest"}
all_requirements_met=true

ensure_kafka_is_running() {
  if ! sudo lsof -i :9092 >/dev/null 2>&1; then
    echo "ERROR: Kafka is not running on port 9092"
    echo "Please start Kafka before running $test_case test"
    all_requirements_met=false
  fi
}

ensure_localstack_is_running() {
  if ! sudo lsof -i :4566 >/dev/null 2>&1; then
    echo "ERROR: Localstack is not running on port 4566"
    echo "Please start Localstack before running $test_case test"
    all_requirements_met=false
  fi
}

add_test_case() {
  local class_name
  class_name=$(find src/test -name "$test_case.java")
  class_name=${class_name#src/test/java/}
  class_name=${class_name%.java}
  class_name=${class_name//\//.}
  tests+=($class_name)
}

tests=()
for test_case in $test_cases
do
  case "$test_case" in
    KafkaConsumerServiceIntegrationTest)
      ensure_kafka_is_running
      add_test_case
      ;;
    VideoEventRepositoryIntegrationTest)
      ensure_localstack_is_running
      add_test_case
      ;;
    KafkaConsumerServiceTest)
      add_test_case
      ;;
    *)
      echo "Invalid test_case!"
      exit 1
  esac
done

if [ "$all_requirements_met" = false ]; then
  echo "Requirements not met, skipping tests"
  exit 1
fi

for test in "${tests[@]}" 
do
  case "$test" in
    *KafkaConsumerServiceIntegrationTest*)

      # TODO: fix the configuration in test/resources/application*.yml and remove the next lines:
      # Ref: https://docs.spring.io/spring-boot/reference/features/logging.html#features.logging.log-format
      log=logs/test.log
      mkdir -p ${log%/*}
      > $log

      ;;
  esac
done

test_args=""
for test in "${tests[@]}"
do
  test_args="$test_args --tests $test"
done

cmd="./gradlew clean test -Pintegration-tests $test_args"
echo Running \'$cmd "$@"\' ...
$cmd "$@"

for test in "${tests[@]}"
do
  case "$test" in
    *KafkaConsumerServiceIntegrationTest*)
      echo
      echo Integration test log "(file $log) for $test":
      echo
      cat=$(which batcat) &> /dev/null && cat='batcat -n' || cat=$(which cat)
      $cat $log
      ;;
  esac
done
