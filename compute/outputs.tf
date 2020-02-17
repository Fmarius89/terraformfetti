output "target_id" {
  value = "${aws_instance.tf_server.*.id}"
}
