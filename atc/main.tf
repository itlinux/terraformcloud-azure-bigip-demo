provider bigip {
  alias    = "one"
  address = "https://${azurerm_public_ip.vm01mgmtpip.ip_address}"
  username = var.uname
  password = var.upassword
}
provider bigip {
  alias    = "two"
  address = "https://${azurerm_public_ip.vm02mgmtpip.ip_address}"
  username = var.uname
  password = var.upassword
}