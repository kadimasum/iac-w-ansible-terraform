output "security_group_id" {
  value = module.server_sg.id
}

output "server_ids" {
  value = { for k, m in module.servers : k => m.id }
}
