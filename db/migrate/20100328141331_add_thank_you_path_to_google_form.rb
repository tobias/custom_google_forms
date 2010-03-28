class AddThankYouPathToGoogleForm < ActiveRecord::Migration
  def self.up
    add_column :google_forms, :thank_you_path, :string
  end

  def self.down
    remove_column :google_forms, :thank_you_path
  end
end
