class CreateAppTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :app_tokens do |t|
      t.belongs_to :user, foreign_key: true
      t.string :token
      t.datetime :user_agent
      t.datetime :last_used

      t.timestamps
    end
    add_index :app_tokens, :token, unique: true
  end
end
