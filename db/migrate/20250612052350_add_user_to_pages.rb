class AddUserToPages < ActiveRecord::Migration[7.2]
  def change
    # This doesn't need a default value since all pages will need to be deleted before running this migration
    add_reference :pages, :user, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
