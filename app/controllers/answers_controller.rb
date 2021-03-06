class AnswersController < ApplicationController
  include Voted
  include Commented

  before_action :authenticate_user!
  before_action :find_answer, only: %i[destroy update best]
  before_action :find_question, only: %i[new create]
  after_action :publish_answer, only: %i[create]

  authorize_resource

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    flash.now[:notice] = 'Your answer was successfully created.' if @answer.save
  end

  def update
    if @answer.update(answer_params)
      flash.now[:notice] = 'Your answer was successfully updated.'
    else
      flash.now[:alert] = 'Fail answer update.'
    end
    @question = @answer.question
  end

  def destroy
    @answer.destroy
    flash.now[:notice] = 'Your answer was successfully deleted.'
  end

  def best
    @answer.set_best!
  end

  private

  def publish_answer
    return if @answer.errors.any?

    ActionCable.server.broadcast(
      "data-question-id=#{@question.id}",
      {
        answer: ApplicationController.render(
          partial: 'answers/answer_channel',
          locals: {
            answer: @answer,
            current_user: current_user,
          }
        ),
        answer_id: @answer.id,
        answer_user_id: @answer.user_id,
        question_user_id: @question.user_id
      }
    )
  end

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: %i[url name])
  end
end
