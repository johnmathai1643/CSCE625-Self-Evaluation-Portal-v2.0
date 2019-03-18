class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.text :answer
      t.boolean :is_answer

      t.timestamps
    end
  end
end
