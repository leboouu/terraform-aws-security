output "example_record_id" {
  description = "ID of the example Cloudflare DNS record"
  value       = cloudflare_record.example.id
}

output "example_record_name" {
  description = "Name of the example Cloudflare DNS record"
  value       = cloudflare_record.example.name
}
