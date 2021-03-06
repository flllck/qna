module Api
  module V1
    class QuestionsController < Api::V1::BaseController
      authorize_resource

      def index
        @questions = Question.all
        render json: @questions
      end

      def show
        render json: question
      end

      def create
        @question = current_resource_owner.questions.new(question_params)

        if @question.save
          render json: @question
        else
          head :unprocessable_entity
        end
      end

      def update
        if question.update(question_params)
          render json: question
        else
          head :unprocessable_entity
        end
      end

      def destroy
        head :ok if question.destroy
      end

      private

      def question
        @question ||= Question.find(params[:id])
      end

      def question_params
        params.require(:question).permit(:title, :body)
      end
    end
  end
end
