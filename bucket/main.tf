# Create a random id
resource "random_id" "tf_bucket_id" {
  byte_length = 2
}

# Create the bucket
resource "aws_s3_bucket" "serverless" {
    bucket        = "${var.project_name}-${random_id.tf_bucket_id.dec}"
    acl           = "public-read"
    #policy        = "${file("policy.json")}"
    force_destroy =  true

    website {
       index_document = "index.html"
    }
    tags {
      Name = "fetti-serverless"
    }

  provisioner "local-exec" {
     command = "aws s3 cp /home/ec2-user/aws-serverless-workshops-master/WebApplication/1_StaticWebHosting/website s3://${aws_s3_bucket.serverless.id} --recursive"

}
 }

rovider "aws" {
  region = "${var.aws_region}"
}


resource "aws_s3_bucket_policy" "serverless" {
  bucket = "${aws_s3_bucket.serverless.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.serverless.id}/*"
    }
  ]
}
POLICY
}
