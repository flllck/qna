class Answer < ApplicationRecord
  include Votable
  include Linkable
  include Fileable
  include Commentable

  default_scope { order(best: :desc).order(created_at: :asc) }

  belongs_to :question
  belongs_to :user

  validates :body, presence: true

  def set_best!
    transaction do
      question.answers.update_all(best: false)
      update!(best: true)
      question.reward&.update!(user: user)
    end
  end
end
