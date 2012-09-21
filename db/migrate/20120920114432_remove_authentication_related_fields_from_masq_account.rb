class RemoveAuthenticationRelatedFieldsFromMasqAccount < ActiveRecord::Migration
  def up
    if defined?(Account)
      Masq::Account.all.each { |masq_account|
        unless Account.find_by_email(masq_account.email) || Account.find_by_login(masq_account.login)
          account = Account.new(:login => masq_account.login, :email => masq_account.email)
          account.save(:validate => false)
        end
      }
    end

    remove_column :masq_accounts, :login
    remove_column :masq_accounts, :email
    remove_column :masq_accounts, :crypted_password
    remove_column :masq_accounts, :salt
    remove_column :masq_accounts, :remember_token
    remove_column :masq_accounts, :password_reset_code
    remove_column :masq_accounts, :activation_code
    remove_column :masq_accounts, :last_authenticated_at
    remove_column :masq_accounts, :remember_token_expires_at
    remove_column :masq_accounts, :activated_at
  end

  def down
    add_column :masq_accounts, :activated_at, :datetime
    add_column :masq_accounts, :remember_token_expires_at, :datetime
    add_column :masq_accounts, :last_authenticated_at, :datetime
    add_column :masq_accounts, :activation_code, :string
    add_column :masq_accounts, :password_reset_code, :string
    add_column :masq_accounts, :remember_token, :string
    add_column :masq_accounts, :salt, :string
    add_column :masq_accounts, :crypted_password, :string
    add_column :masq_accounts, :email, :string
    add_column :masq_accounts, :login, :string
  end
end
