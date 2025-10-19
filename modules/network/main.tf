resource "azurerm_virtual_network" "avn" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_virtual_network.avn.resource_group_name
  virtual_network_name = azurerm_virtual_network.avn.name
  address_prefixes     = each.value.address_prefixes
}
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  resource_group_name = azurerm_virtual_network.avn.resource_group_name
  location            = azurerm_virtual_network.avn.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_ass" {
  subnet_id                 = azurerm_subnet.subnet["application_subnet"].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

