# This migration comes from masq (originally 20120312120001)
class AddAccountIdColumnToMasqAccounts < ActiveRecord::Migration
  def up
    add_column :masq_accounts, :account_id, :integer
  end

  def down
    remove_column :masq_accounts, :account_id
  end
end
