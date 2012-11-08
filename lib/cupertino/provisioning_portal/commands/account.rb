command :account do |c|
  c.syntax = 'ios account'
  c.summary = 'Select active account'
  c.description = ''

  c.action do |args, options|
    new_account = args.first rescue nil

    if new_account
      config['current'] = new_account
      save_config

      if config['accounts'][new_account]
        puts "Active account changed to #{config['accounts'][new_account]} (#{new_account})."
      else
        puts "Active account changed to #{new_account}."
      end
    else
      puts "Accounts:"
      config['accounts'].each do |key, account|
        is_active = config['current'] == key
        puts (is_active ? "  * " : "    ") + key + ": " + account + (is_active ? " (Active)" : "")
      end
    end
  end
end
