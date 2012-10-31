xml.instruct!
xml.personaConfig(:serverIdentifier => endpoint_url, :version => '1.0') do
	xml.persona(identifier(current_account.masq_account), :displayName => current_account.login) if account_signed_in?
end
