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

def convert_to_hash(acc, current)
  key = current.shift
  acc[key] ||= {}
  acc[key].merge!({ current.shift => current.shift })
  acc
end



def parse_zone_file(raw)
  raw
    .reject { |line| line.include? '#' }
    .map(&:strip)
    .reject(&:empty?)
    .map { |line| line.strip.split(', ') }
    .reduce({}) { |acc, current| convert_to_hash(acc, current) }
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

dns_records = parse_zone_file(dns_raw)
A_record = dns_records["A"]
CNAME = dns_records["CNAME"]
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
