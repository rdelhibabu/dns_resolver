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
    source_destination = line.chomp().split(", ")
    [source_destination[1], source_destination[2]]
  }.to_h
end

def resolve(dns_records, lookup_chain, domain)
  block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
  re = /\A#{block}\.#{block}\.#{block}\.#{block}\z/
  if dns_records[domain] == nil
    print "Error: record not found for "
  elsif (re =~ dns_records[domain])
    lookup_chain.push(dns_records[domain])
  else
    lookup_chain.push(dns_records[domain])
    resolve(dns_records, lookup_chain, dns_records[domain])
  end
  lookup_chain
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
