Rails.application.routes.draw do
  get "/",      to: "home#index"
  get "/error", to: "home#trigger_error"
end
