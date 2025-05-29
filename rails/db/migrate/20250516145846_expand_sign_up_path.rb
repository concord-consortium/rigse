class ExpandSignUpPath < ActiveRecord::Migration[8.0]
  def up
    # At the time of writing this migration, the production database was MySQL 8 for learn
    # and MySQL 5.7 for ngsa. The `ALGORITHM=INPLACE` option is not supported in MySQL 5.7,
    # so we need to handle the case where it fails.
    begin
      execute "ALTER TABLE users MODIFY COLUMN sign_up_path VARCHAR(1024), ALGORITHM=INPLACE, LOCK=NONE;"
    rescue ActiveRecord::StatementInvalid => e
      if e.message.include?("ALGORITHM=INPLACE")
        puts "INPLACE algorithm failed, retrying with COPY algorithm..."
        execute "ALTER TABLE users MODIFY COLUMN sign_up_path VARCHAR(1024), ALGORITHM=COPY;"
      else
        raise e
      end
    end
  end

  def down
    # this can't be done using the inplace algorithm unfortunately
    execute "ALTER TABLE users MODIFY COLUMN sign_up_path VARCHAR(255);"
  end
end

