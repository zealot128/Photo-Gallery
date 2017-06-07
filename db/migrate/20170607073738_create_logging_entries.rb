class CreateLoggingEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :logging_entries do |t|
      t.integer :severity, default: 0
      t.text :message
      t.text :backtrace
      t.datetime :created_at
    end
  end
end
