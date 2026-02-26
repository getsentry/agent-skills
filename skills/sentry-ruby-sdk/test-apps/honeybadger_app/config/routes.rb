Rails.application.routes.draw do
  get "/",              to: "alerts#index"
  get "/trigger_error", to: "alerts#trigger_error"
  get "/notify_error",  to: "alerts#notify_error"
end
