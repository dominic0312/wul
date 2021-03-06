class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :trans_type
      t.decimal :operation_amount
      t.decimal :account_before
      t.decimal :account_after
      t.decimal :frozen_before
      t.decimal :frozen_after

      t.timestamps
    end
  end
end
