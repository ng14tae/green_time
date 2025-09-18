class Api::V1::HealthController < Api::V1::ApplicationController
  def check
    render json: { status: 'ok', message: 'Rails API is running!' }
  end
end