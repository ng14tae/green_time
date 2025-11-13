class FormsController < ApplicationController
  skip_before_action :authenticate_user_with_line_support!
  def custom_form
  end

  def thanks
  end
end
