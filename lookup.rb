def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

dns_raw.delete_if { |x| x.include? "#" }
dns_raw.delete_if { |x| x == "\n" }
dns_raw.each { |x| x.delete! "\n" }
dns_raw = dns_raw.map { |x| x.split(", ") }

def parse_dns(array)
  hash = {}
  array.map do |nested|
    key = nested.shift
    hash[key] ||= {}
    hash[key].merge!({ nested.shift => nested.shift })
  end
  hash
end


def resolve(dns_records, lookup_chain, domain)
  if A_record.keys.include? domain
    lookup_chain << A_record[domain]
  elsif CNAME.keys.include? domain
    lookup_chain << CNAME[domain]
    resolve(dns_records, lookup_chain, CNAME[domain])
  else
    lookup_chain << "record not found ".capitalize
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
A_record = dns_records["A"]
CNAME = dns_records["CNAME"]
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
