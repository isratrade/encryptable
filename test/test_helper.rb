require "minitest/autorun"
require "active_record"
require "encryptable"

# Test against real ActiveRecord models.
# Very much based on the test setup in
# https://github.com/iain/encryptable_columns/

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

silence_stream(STDOUT) do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.string :title_sv, :title_en, :title_fi
      t.string :body_sv, :body_en, :body_fi
    end
  end
end
