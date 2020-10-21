resource "aws_iam_user" "user" {
  name = "${var.project_name}_bucketeer"
}

resource "aws_iam_access_key" "project_rw" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  count = var.bucket_arn != "" ? 1 : 0
  name  = "${var.project_name}_bucket_policy"
  user  = aws_iam_user.user.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
      "Resource": ["arn:aws:s3:::*"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${var.bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Condition": {"StringEquals":{"s3:prefix":["","${var.project_name}/"],"s3:delimiter":["/"]}},
      "Resource": ["${var.bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Condition": {"StringLike":{"s3:prefix":["${var.project_name}/*"]}},
      "Resource": ["${var.bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${var.bucket_arn}/${var.project_name}",
        "${var.bucket_arn}/${var.project_name}/*"
      ]
    }
  ]
}
POLICY

}

resource "aws_iam_user_policy" "secret_policy" {
  count = var.secret_bucket_arn != "" ? 1 : 0
  name  = "${var.project_name}_secret_bucket_policy"
  user  = aws_iam_user.user.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
      "Resource": ["arn:aws:s3:::*"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${var.secret_bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Condition": {"StringEquals":{"s3:prefix":["","${var.project_name}/"],"s3:delimiter":["/"]}},
      "Resource": ["${var.secret_bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Condition": {"StringLike":{"s3:prefix":["${var.project_name}/*"]}},
      "Resource": ["${var.secret_bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${var.secret_bucket_arn}/${var.project_name}",
        "${var.secret_bucket_arn}/${var.project_name}/*"
      ]
    }
  ]
}
POLICY

}

