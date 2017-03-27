module Dynatrace
  class Util
    def self.parse_cmd(cmd, opts)
      result = ''

      unless opts.empty?
        opts.each do | key, value |
          result << key.to_s + "="

          unless value.nil?
            result << "'" + value.to_s + "'"
          end

          result << ' '
        end
      end

      result << cmd
    end
  end
end