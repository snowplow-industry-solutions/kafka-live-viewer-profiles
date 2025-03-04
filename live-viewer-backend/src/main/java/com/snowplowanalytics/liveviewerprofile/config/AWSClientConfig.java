package com.snowplowanalytics.liveviewerprofile.config;

import org.springframework.beans.factory.annotation.Value;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;

public abstract class AWSClientConfig {

  @Value("${aws.credentials.access-key:access-key}")
  protected String awsAccessKey;

  @Value("${aws.credentials.secret-key:secret-key}")
  protected String awsSecretKey;

  @Value("${aws.region:eu-west-2}")
  protected String awsRegion;

  protected AwsCredentialsProvider amazonAWSCredentialsProvider() {
    return StaticCredentialsProvider.create(AwsBasicCredentials.create(awsAccessKey, awsSecretKey));
  }

}