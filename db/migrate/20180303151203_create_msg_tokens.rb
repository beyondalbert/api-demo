class CreateMsgTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :msg_tokens do |t|
      t.string :account
      t.string :value

      t.timestamps
    end
  end
end
