class CreatePostLogs < ActiveRecord::Migration
  def change
    create_table :post_logs do |t|
      t.text :data

      t.timestamps
    end
  end
end
