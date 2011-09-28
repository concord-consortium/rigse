    #
    # report the number of students successfully imported to ActiveRecord
    # for each district:
    # @rd.verify_users
    #
    # district 07: total import records: 8533, imported to AR: 5094, missing: 3439
    # district 16: total import records: 2631, imported to AR: 6, missing: 2625
    # district 17: total import records: 1740, imported to AR: 0, missing: 1740
    # district 39: total import records: 3551, imported to AR: 1, missing: 3550
    # TODO: Some report method
    def verify_users
      report "Imported ActiveRecord entities by district:"
      log_message("skipping verification", {:log_level => 'warn'})
      # @districts.each do |district|
      #   begin
      #     verify_user_imported(district)
      #   rescue Exception => e
      #     log_message("missing district data for: #{district}",{:log_level => 'error'})
      #     log_message("#{e.message}",{:log_level => 'error'})
      #   end
      # end
    end

    #
    # report the number of students successfully imported to ActiveRecord
    # for a given district:
    # @rd.verify_user_imported('16')
    # => district 16: total import records: 2631, imported to AR: 1706, missing: 925
    def verify_user_imported(district=@districts.first)
      ["student","staff"].each do |type|
        file_name = "#{@district_data_root_dir}/#{district}/current/#{type}.csv"
        missing = 0; found = 0; total = 0;
        open(file_name) do |fd|
          fd.each do |line|
             if line =~ /\d+\s*,\s*(\S+)/
               login = $1
               rites_login = ExternalUserDomain.external_login_to_login(login)
               if ExternalUserDomain.external_login_exists?(login)
                 found += 1
               else
                 missing += 1
               end
               total += 1
             end
          end
        end
        report "district: #{district}, #{type} records found in #{File.basename(file_name)}: #{total}, imported to AR: #{found}, missing: #{missing}"
      end
    end

