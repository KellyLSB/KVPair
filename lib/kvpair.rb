unless defined? ActiveRecord::Base
	raise StandardError, "ActiveRecord is not available."
end

module KellyLSB
module KVPair
	extend ActiveSupport::Concern

	module ClassMethods
		def kvpair(ns)
			nsm = ns.to_s + '-'
			nse = ns.to_s + '='
			nsa = ns.to_s + '<<'
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

					# Touch the updated_at stamp
					self.touch
					self.save!

					# Return the new pair
					return self.send(ns)
				end

				send(:define_method, nsa.to_sym) do |input|

					# Remove unknown keys
					input.delete_if{|k,v| v.nil?}

					# Upsert the record
					input.each do |key, val|
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

					# Return the new pair
					return self.send(ns)
				end

				send(:define_method, nsm.to_sym) do |input|

					# Convert to array
					input = input.keys if input.is_a?(Hash)
					input = [input] if input.is_a?(String)
					input = [input] if input.is_a?(Symbol)

					# Delete the keys
					Kvpair.delete_all(["`owner` = ? && `namespace` = ? && (`key` IN (?) || `value` = '' || `value` IS NULL)", "#{self.class.name}:#{self.id}", ns, input])

					# Return the new pair
					return self.send(ns)
				end
			})
			send(:extend, Module.new {
				send(:define_method, ns.to_sym) do |input|
					query = self

					tmp = 0
					input.each do |key, val|
						query = query.joins("INNER JOIN `kvpairs` as `kvpairs#{tmp.to_s}` ON `kvpairs#{tmp.to_s}`.`owner` = CONCAT('#{self.name}:', `#{self.table_name}`.`id`)")
						query = query.where("`kvpairs#{tmp.to_s}`.`namespace` = ? && `kvpairs#{tmp.to_s}`.`key` = ? && `kvpairs#{tmp.to_s}`.`value` = ?", ns, key, val.to_s)
						tmp += 1
					end

					query
				end
			})
		end
	end
end
end

ActiveRecord::Base.send(:include, KellyLSB::KVPair)