provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "iamrole_lambda_spider" {
  name               = "iamrole_lambda_spider"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iampol_lambda_spider" {

  name        = "iampol_lambda_spider"
  path        = "/"
  description = "AWS IAM Policy for lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_lambda_spider_1" {
  role       = aws_iam_role.iamrole_lambda_spider.name
  policy_arn = aws_iam_policy.iampol_lambda_spider.arn
}

data "archive_file" "spider_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/spider/"
  output_path = "${path.module}/zip/spider.zip"
}

resource "aws_lambda_function" "spider_lambda_func" {
  filename      = "${path.module}/zip/spider.zip"
  function_name = "spider_lambda_func"
  role          = aws_iam_role.iamrole_lambda_spider.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_lambda_spider_1]
  timeout       = "30"
}
