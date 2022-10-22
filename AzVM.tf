resource "azurerm_resource_group" "rg" {
  name     = "test-env"
  location = var.location
}


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "interna-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "PubIP" {
  name                = "LinuxVmIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vnic" {
  name                = "vnic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PubIP.id
  }
}

resource "azurerm_linux_virtual_machine" "LinuxVM" {
  name                            = "LinuxVM"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = "prateek"
  admin_password                  = "Prateek@143"
  disable_password_authentication = false
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
  network_interface_ids = [azurerm_network_interface.vnic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  custom_data = file("C:\\Users\\pupadhyay23\\OneDrive - DXC Production\\Documents\\Zoom\\Python Practice\\Terraform\\script.sh")

}

resource "azurerm_network_security_group" "nsg-linux" {
  name                = "nsg-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [azurerm_subnet.subnet,azurerm_network_interface.vnic]
  security_rule = [
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "22"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "AllowAnyCustom22Inbound"
      priority                                   = 100
      protocol                                   = "*"
      source_address_prefix                      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "8080"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "AllowAnyCustom8080Inbound"
      priority                                   = 110
      protocol                                   = "*"
      source_address_prefix                      = "*"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
    },
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg-subnet-Association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-linux.id
}

