class AgentsController < ApplicationController
  def show
    expires_in 10.minutes, public: true
    render formats: :text
  end
end
