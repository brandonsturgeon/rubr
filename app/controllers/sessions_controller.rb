class SessionsController < ApplicationController
  layout 'blank'
  skip_before_action :authorize

  def new
    puts "In Sessions#new"
    if current_account
      puts "Currently in a session"
      puts "Redirecting to dashboard_url: #{dashboard_url}"
      redirect_to dashboard_url
    end
  end

  def create
    puts "In Sessions#create"
    user_name = params[:user_name]
    account = Account.where(user_name: user_name).first

    if account && account.authenticate(params[:password])
      cookies[:auth_token] = account.auth_token
      return redirect_to dashboard_url

    else
      flash.now.alert = "User Name or Password Incorrect"
      render "new"
    end
  end

  def destroy
    puts "In Sessions#destroy"
    cookies.clear
    session.clear
    redirect_to sign_in_url
  end
end
