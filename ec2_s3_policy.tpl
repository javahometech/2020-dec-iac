{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:PubObject"
        ],
        "Effect": "Allow",
        "Resource": "${s3_bucket_arn}/*"
      }
    ]
  }