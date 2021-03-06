class QuestionsController < ApplicationController
  include Voted
  include Commented

  before_action :authenticate_user!, except: %i[index show]
  before_action :find_question, only: %i[show update destroy]
  before_action :find_subscription, only: %i[show update]

  after_action :publish_question, only: %i[create]

  authorize_resource

  def index
    @questions = Question.all
  end

  def show
    @answer = Answer.new
    @answer.links.new
  end

  def update
    if @question.update(question_params)
      flash.now[:notice] = 'Your question was successfully updated.'
    else
      flash.now[:alert] = 'Fail question update.'
    end
  end

  def new
    @question = Question.new
    @question.links.new
    @question.build_reward
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      redirect_to @question, notice: 'Your question successfully created'
    else
      render :new
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: 'Your question successfully deleted'
  end

  private

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast(
      'questions',
      ApplicationController.render(
        partial: 'questions/question',
        locals: { question: @question }
      )
    )
  end

  def find_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def find_subscription
    @subscription = @question.subscriptions.find_by(user: current_user)
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
                                                    links_attributes: %i[name url],
                                                    reward_attributes: %i[name image])
  end
end
