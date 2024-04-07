class CreateContactsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :phoneNumber
      t.string :email
      t.integer :linkedId
      t.integer :linkPrecedence
      t.timestamp :deletedAt

      t.timestamps null: false
    end
  end
end
