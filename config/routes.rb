Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'root#index'

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/, defaults: {locale: I18n.default_locale} do
    post '/parse' => 'root#parse'
    get '/js/:name' => 'root#js', name: /[a-zA-Z0-9]+/
  end

  get '/:locale' =>  'root#index', locale: /#{I18n.available_locales.join('|')}/, as: :root_locale
end
