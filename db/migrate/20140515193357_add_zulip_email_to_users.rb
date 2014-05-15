class AddZulipEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zulip_email, :string
  end
end
