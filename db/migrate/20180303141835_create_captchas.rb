class CreateCaptchas < ActiveRecord::Migration[5.1]
  def change
    create_table :captchas do |t|
      t.string :value
      t.text :image_base64

      t.timestamps
    end
  end
end
