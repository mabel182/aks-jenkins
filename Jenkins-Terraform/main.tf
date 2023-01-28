resource "azurerm_resource_group" "rg-demo" {
  name = var.rg_name
  location = var.rg_location
  tags = {
    "Grupo" = var.group
  }
}

resource "azurerm_virtual_network" "vnet-demo" {
    name = "my-vnet"
    address_space = ["12.0.0.0/16"]
    location = azurerm_resource_group.rg-demo.location
    resource_group_name = azurerm_resource_group.rg-demo.name
}

resource "azurerm_subnet" "subnet-demo" {
  name = "internal"
  resource_group_name = azurerm_resource_group.rg-demo.name
  virtual_network_name = azurerm_virtual_network.vnet-demo.name
  address_prefixes = ["12.0.2.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                      = "public-ip"
  location                  = azurerm_resource_group.rg-demo.location
  resource_group_name       = azurerm_resource_group.rg-demo.name
  allocation_method         = "Static"
   tags = {
    "Grupo" = var.group
  }

}
resource "azurerm_network_interface" "nic-demo" {
  name                = "myNic"
  location            = azurerm_resource_group.rg-demo.location
  resource_group_name = azurerm_resource_group.rg-demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-demo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}


resource "tls_private_key" "rsa-demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg-demo.location
  resource_group_name   = azurerm_resource_group.rg-demo.name
  network_interface_ids = [azurerm_network_interface.nic-demo.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.rsa-demo.public_key_openssh
  }

 
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${azurerm_public_ip.publicip.ip_address},' --private-key ${var.ssh_private_key} playbook.yaml -i inventory --extra-vars \"ansible_ssh_host= ${azurerm_public_ip.publicip.ip_address}\" "
 
  }
}