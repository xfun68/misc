require 'tzinfo'

timezone = ARGV[0]
puts TZInfo::Timezone.new(timezone).current_period.utc_offset

