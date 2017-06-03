#!/bin/bash

# Unit test script 
# Easy to copy paste in your terminal
# Pascal Andy 2017-06-03_13h39

# LEAVE THIS COMMENT OUT! Else it overide the $ENV_IMG_BUILD_EDGE during build time
#ENV_IMG_BUILD_EDGE=devmtl/ghost-fire:edge_2017-03-26_18H02

CTN_NAME="ghost-unittest"
IMG_TEST="$ENV_IMG_BUILD_EDGE"

TEST_01_CMD="uname -a"
TEST_01_NOTE="uname"

TEST_02_CMD="node --version"
TEST_02_NOTE="node version"

TEST_03_CMD="cat /ghost/content/themes/casper/package.json"
TEST_03_NOTE="FirePress Klimax version"

TEST_04_CMD="cat /ghost/content/themes/casper-foundation/package.json"
TEST_04_NOTE="casper-foundation version"

TEST_05_CMD="curl http://localhost:2368/"
TEST_05_NOTE="curl localhost"
\
echo; \
echo "--- Unit Test for image: <$IMG_TEST> - Start ---"; echo;
\
docker run -d \
--name $CTN_NAME \
$IMG_TEST; sleep 0.1; \
echo "--- Container Started: $CTN_NAME ---"; echo; \
\
docker exec -it $CTN_NAME \
$TEST_01_CMD; sleep 0.1; \
echo "--- TEST 01 | $TEST_01_NOTE ---"; echo; \
\
docker exec -it $CTN_NAME \
$TEST_03_CMD; sleep 0.1; \
echo "--- TEST 02 | $TEST_02_NOTE ---"; echo; \
\
docker exec -it $CTN_NAME \
$TEST_03_CMD | grep "version"; sleep 0.1; \
echo "--- TEST 03 | $TEST_03_NOTE ---"; echo; \
\
docker exec -it $CTN_NAME \
$TEST_04_CMD | grep "version"; sleep 0.1; \
echo "--- TEST 04 | $TEST_04_NOTE ---"; echo; \
#\
#docker exec -it $CTN_NAME \
#$TEST_05_CMD; sleep 0.1; echo; \
#echo "--- TEST 05 | $TEST_05_NOTE ---"; echo; \
\
docker rm -f $CTN_NAME; sleep 0.1; \
echo "--- Container Removed: $CTN_NAME ---"; echo; \
\
echo "--- Unit Test for image: <$IMG_TEST> - End ---"; \
echo;