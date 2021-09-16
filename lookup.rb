def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw.map { |line|
    parts = line.chomp().split(", ")
    [parts[1], parts[2]]
  }.to_h
end

def resolve(dns_records, domain,lookup_array=[domain])
  ip_range_regex = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
  ip_address_regex = /\A#{ip_range_regex}\.#{ip_range_regex}\.#{ip_range_regex}\.#{ip_range_regex}\z/
  if dns_records[domain] == nil
    print "Error: record not found for "
  elsif (ip_address_regex =~ dns_records[domain])
    lookup_array.push(dns_records[domain])
  else
    lookup_array.push(dns_records[domain])
    resolve(dns_records,  dns_records[domain],lookup_array)
  end
  lookup_array
end

dns_records = parse_dns(dns_raw)
lookup_chain = resolve(dns_records,  domain)
puts lookup_chain.join(" => ")
