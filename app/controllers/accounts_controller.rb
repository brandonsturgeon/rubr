class AccountsController < ApplicationController
  skip_before_action :authorize
  layout "blank", only: [:new]

  def new
    @account = Account.new
  end

  def create
    # TODO: @account needs to be valid here
    puts "Created account: ------------"
    puts @account.inspect
    puts "End Created account: ----------"

    # Sanitizing user input, excludes email and password
    raw_account_params = params[:account]
    account_params = {}
    raw_account_params.each do |key, value|
      key = key.to_sym
      #if key == :password || key == :email
      if [:password, :email].include?(key)
        account_params[key] = value
      else
        account_params[key] = value.sanitize
      end
    end

    puts account_params.inspect

    if account_params[:password] == account_params[:password_confirmation]
      a = Account.new(
        first_name: account_params[:first_name],
        last_name: account_params[:last_name],
        user_name: account_params[:user_name],
        zip: account_params[:zip],
        description: account_params[:description],
        age: account_params[:age],
        gender: account_params[:gender],
        looking_for: account_params[:looking_for],
        email: account_params[:email],
        password: account_params[:password]
      )

      if a.save
        flash[:alert] = "Successfully created account!"
        return redirect_to "/sign_in"
      else
        #TODO: get this part working
        puts a.errors.inspect
        @account = Account.new
        return render action: 'new'
      end
    end
  end

  # GET /profile
  def show
    @account = current_account
  end

  # GET /profile/edit
  def edit
    @account = current_account
  end

  # POST /profile/update
  def update
    @account = current_account
    if @account.update(trusted_params)
      flash[:alert] = "Successfully updated profile!"
      redirect_to "/profile"
    else
      return render action: 'edit'
    end
  end

  # API call
  # Returns true or false
  # TODO: maybe have this return # of unread mails
  # TODO: make this more secure
  def has_unread_mail
      unread_mail = Message.where(receiver_id: current_account.id, read: false).count
      respond_to do |format|
          format.json { render json: unread_mail > 0 }
      end
      return 200
  end

  private
    #TODO: rename this to account_params
    def trusted_params
      params.require(:account).permit(:first_name, :last_name, :user_name, :zip, :description, :age, :gender, :looking_for, :email, :password)
    end

end
