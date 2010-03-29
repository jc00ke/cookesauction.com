Admin.controllers :emails do

  get :index do
    @emails = Email.all
    render 'emails/index'
  end

  get :new do
    @email = Email.new
    render 'emails/new'
  end

  post :create do
    @email = Email.new(params[:email])
    if @email.save
      flash[:notice] = 'Email was successfully created.'
      redirect url(:emails, :edit, :id => @email.id)
    else
      render 'emails/new'
    end
  end

  get :edit, :with => :id do
    @email = Email.get(params[:id])
    render 'emails/edit'
  end

  put :update, :with => :id do
    @email = Email.get(params[:id])
    if @email.update(params[:email])
      flash[:notice] = 'Email was successfully updated.'
      redirect url(:emails, :edit, :id => @email.id)
    else
      render 'emails/edit'
    end
  end

  delete :destroy, :with => :id do
    email = Email.get(params[:id])
    if email.destroy
      flash[:notice] = 'Email was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Email!'
    end
    redirect url(:emails, :index)
  end
end