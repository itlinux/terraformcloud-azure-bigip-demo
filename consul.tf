# consul vm

# Create NIC
resource "azurerm_network_interface" "consul01-ext-nic" {
  name                = "${var.prefix}-consul01-ext-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.External.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.consul01ext
    primary                       = true
  }

  tags = {
    Name        = "${var.environment}-consul01-ext-int"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = "app1"
  }
}

# Associate network security groups with NICs
resource "azurerm_network_interface_security_group_association" "consul01-ext-nsg" {
  network_interface_id      = azurerm_network_interface.consul01-ext-nic.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Setup Onboarding scripts
data "template_file" "consul_onboard" {
  template = file("${path.module}/consul-onboard.sh.tpl")

  vars = {
    CONSUL_VERSION = "1.7.2"
  }
}

# Create consul VM
resource azurerm_linux_virtual_machine consulvm {
  name                            = "consulvm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  network_interface_ids           = [azurerm_network_interface.consul01-ext-nic.id]
  size                            = "Standard_B1ms"
  admin_username                  = var.uname
  admin_password                  = var.upassword
  disable_password_authentication = false
  computer_name                   = "consul01"
  custom_data                     = base64encode(data.template_file.consul_onboard.rendered)

  os_disk {
    name                 = "consulOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name        = "${var.environment}-consul01"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
  }
}
