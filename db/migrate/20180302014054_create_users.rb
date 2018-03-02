class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :phone
      t.string :password_digest
      t.string :jwt_token
      t.string :pic_token
      t.string :msg_token

      t.timestamps
    end
  end
end
