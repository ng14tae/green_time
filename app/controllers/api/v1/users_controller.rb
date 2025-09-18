class Api::V1::UsersController < Api::V1::ApplicationController
  def index
    users = [
      { id: 1, name: "テストユーザー1", line_id: "U123456" },
      { id: 2, name: "テストユーザー2", line_id: "U789012" }
    ]

    render json: {
      status: 'success',
      data: users
    }
  end

  def create
    # LIFFから送られてきたユーザー情報を保存
    user_params = params.require(:user).permit(:line_id, :display_name)

    render json: {
      status: 'success',
      message: 'User created successfully',
      data: user_params
    }
  end
end