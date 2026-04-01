output "security_group_id" {
  value = module.server_sg.id
}

output "server_ids" {
  value = { for k, m in module.servers : k => m.id }
}

output "server_public_ips" {
  value = { for k, m in module.servers : k => m.public_ip }
}

