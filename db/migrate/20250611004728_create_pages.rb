class CreatePages < ActiveRecord::Migration[7.2]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :url
      t.integer :status

      t.timestamps
    end
  end
end
