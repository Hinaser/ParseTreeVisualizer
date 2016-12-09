class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end

Settings['grammar'] ||= Settingslogic.new({})

if Settings.grammar['name'].blank? or Settings.grammar['display_name'].blank?
  raise 'Configuration missing. Please create config/application.yml and set name and display name of a target grammar'
end

Settings.grammar['name'].downcase!
