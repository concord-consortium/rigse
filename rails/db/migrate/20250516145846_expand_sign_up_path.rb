class ExpandSignUpPath < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE users MODIFY COLUMN sign_up_path VARCHAR(1024), ALGORITHM=INPLACE, LOCK=NONE;"
  end

  def down
    # this can't be done using the inplace algorithm unfortunately
    execute "ALTER TABLE users MODIFY COLUMN sign_up_path VARCHAR(255);"
  end
end

