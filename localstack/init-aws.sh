#!/bin/bash

awslocal kinesis create-stream --stream-name collector-good --region eu-west-2 --shard-count 1
awslocal kinesis create-stream --stream-name collector-bad --region eu-west-2 --shard-count 1

awslocal kinesis create-stream --stream-name enriched-good --region eu-west-2 --shard-count 1
awslocal kinesis create-stream --stream-name enriched-bad --region eu-west-2 --shard-count 1
awslocal kinesis create-stream --stream-name enriched-incomplete --region eu-west-2 --shard-count 1
awslocal kinesis create-stream --stream-name pii --region eu-west-2 --shard-count 1

awslocal dynamodb create-table --table-name snowbridge_clients --region eu-west-2 --key-schema AttributeName=ID,KeyType=HASH --attribute-definitions AttributeName=ID,AttributeType=S --billing-mode PAY_PER_REQUEST
awslocal dynamodb create-table --table-name snowbridge_checkpoints --region eu-west-2 --key-schema AttributeName=Shard,KeyType=HASH --attribute-definitions AttributeName=Shard,AttributeType=S --billing-mode PAY_PER_REQUEST
awslocal dynamodb create-table --table-name snowbridge_metadata --region eu-west-2 --key-schema AttributeName=Key,KeyType=HASH --attribute-definitions AttributeName=Key,AttributeType=S --billing-mode PAY_PER_REQUEST

awslocal dynamodb create-table \
    --table-name video_events \
    --region eu-west-2 \
    --attribute-definitions \
        AttributeName=viewer_id,AttributeType=S \
        AttributeName=collector_tstamp,AttributeType=S \
    --key-schema \
        AttributeName=viewer_id,KeyType=HASH \
        AttributeName=collector_tstamp,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
