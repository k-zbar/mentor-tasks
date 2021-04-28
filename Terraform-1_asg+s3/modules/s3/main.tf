resource "aws_s3_bucket" "bucket-for-pages" {
  bucket = var.bucket_name
  acl    = var.acl

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_object" "move-objects" {
  bucket   = aws_s3_bucket.bucket-for-pages.id
  for_each = fileset("${path.module}/files/", "*")
  key      = each.value
  source   = "${path.module}/files/${each.value}"
  etag     = filemd5("${path.module}/files/${each.value}")
}