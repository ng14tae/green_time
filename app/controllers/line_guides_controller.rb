class LineGuidesController < ApplicationController
  skip_before_action :authenticate_user_with_line_support!

  def show
  end
end
