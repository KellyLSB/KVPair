unless defined? ActiveRecord::Base
	raise StandardError, "ActiveRecord is not available."
end

module KellyLSB
module KVPair
	extend ActiveSupport::Concern

	module ClassMethods
		def kvpair(ns)
			nse = ns.to_s + '='
			send(:include, Module.new {
				send(:define_method, ns.to_sym) do |*args|

					# Get the pairs
					pairs = KVPair.where(
						:owner => "#{self.class.name}:#{self.id}",
						:namespace => ns
					)

					# Get the pairs
					pairs.each do |pair|
						data = Hash.new if data.nil?
						data[pair.key] = pair.value
						data[pair.key.to_sym] = pair.value
					end

					# Return data
					return data
				end

				send(:define_method, nse.to_sym) do |input|

					# Upsert the record
					input.each do |key, val|
						KVPair.where(
							:owner => "#{self.class.name}:#{self.id}",
							:namespace => ns,
							:key => key
						).first_or_create(:value => val)
					end

					# Return the switch
					return self.send(ns)
				end
			})
		end
	end
end
end

ActiveRecord::Base.send(:include, KellyLSB::KVPair)