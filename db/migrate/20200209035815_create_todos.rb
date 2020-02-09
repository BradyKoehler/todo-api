class CreateTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.belongs_to :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
