output ipaddress {
  value       = azurerm_public_ip.PubIP.ip_address
  sensitive   = false
}