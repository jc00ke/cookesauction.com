Admin.controllers :submissions do

  get :index do
    @submissions = Submission.all
    render 'submissions/index'
  end

  get :new do
    @submission = Submission.new
    render 'submissions/new'
  end

  post :create do
    @submission = Submission.new(params[:submission])
    if @submission.save
      flash[:notice] = 'Submission was successfully created.'
      redirect url(:submissions, :edit, :id => @submission.id)
    else
      render 'submissions/new'
    end
  end

  get :edit, :with => :id do
    @submission = Submission.get(params[:id])
    render 'submissions/edit'
  end

  put :update, :with => :id do
    @submission = Submission.get(params[:id])
    if @submission.update(params[:submission])
      flash[:notice] = 'Submission was successfully updated.'
      redirect url(:submissions, :edit, :id => @submission.id)
    else
      render 'submissions/edit'
    end
  end

  delete :destroy, :with => :id do
    submission = Submission.get(params[:id])
    if submission.destroy
      flash[:notice] = 'Submission was successfully destroyed.'
    else
      flash[:error] = 'Impossible destroy Submission!'
    end
    redirect url(:submissions, :index)
  end
end