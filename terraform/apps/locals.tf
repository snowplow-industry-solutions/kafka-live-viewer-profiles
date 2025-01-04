locals {
  region            = "eu-west-2"
  ami               = "ami-0e8d228ad90af673b"
  user              = "ubuntu"
  tracker-port      = 3000
  kafka-ui-port     = 8080
  backend-port      = 8180
  viewer-port       = 8280
  collector-port    = 9090
  zip-name          = "snowplow-demo.zip"
  unzip-dir         = "snowplow-demo"
  remote-user-dir   = "/home/${local.user}"
  remote-app-dir    = "${local.remote-user-dir}/${local.unzip-dir}"
  remote-zip-file   = "${local.remote-user-dir}/${local.zip-name}"
  remote-install-sh = "${local.remote-app-dir}/terraform/apps/install.sh"
}
