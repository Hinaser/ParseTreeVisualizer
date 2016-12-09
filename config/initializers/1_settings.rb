class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end

Settings['grammar'] ||= 'ASP'
Settings['grammar'].downcase!
