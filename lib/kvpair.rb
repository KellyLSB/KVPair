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
					pairs = Kvpair.where(
						:owner => "#{self.class.name}:#{self.id}",
						:namespace => "#{ns}"
					)

					# Store data
					data = Hash.new

					# Get the pairs
					pairs.each do |pair|
						data[pair.key] = pair.value
						data[pair.key.to_sym] = pair.value
					end

					# Return data
					return data
				end

				send(:define_method, nse.to_sym) do |input|

					# Remove unknown keys
					input.delete_if{|k,v| v.nil?}

					# Store keys
					keys = Array.new

					# Upsert the record
					input.each do |key, val|
						keys << key

						begin
							Kvpair.where(
								:owner => "#{self.class.name}:#{self.id}",
								:namespace => "#{ns}",
								:key => "#{key}"
							).first_or_create(:value => "#{val}")
						rescue
							pair = Kvpair.where(
								:owner => "#{self.class.name}:#{self.id}",
								:namespace => "#{ns}",
								:key => "#{key}"
							).first

							pair.update_attribute(:value, val) unless pair.nil?

							if pair.nil?
								Kvpair.create(
									:owner => "#{self.class.name}:#{self.id}",
									:namespace => "#{ns}",
									:key => "#{key}",
									:value => "#{val}"
								)
							end
						end
					end

					# Remove unwanted keys
					Kvpair.delete_all(["`owner` = ? && `namespace` = ? && (`key` NOT IN (?) || `value` = '' || `value` IS NULL)", "#{self.class.name}:#{self.id}", ns, keys])

					# Return the switch
					return self.send(ns)
				end
			})
		end
	end
end
end

ActiveRecord::Base.send(:include, KellyLSB::KVPair)