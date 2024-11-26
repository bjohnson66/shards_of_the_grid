class Game < ApplicationRecord
  belongs_to :current_turn_user, class_name: 'User', foreign_key: 'current_turn_user_id', optional: true
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id', optional: true

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
  has_many :tiles, dependent: :destroy

  # Validations
  validates :name, presence: true
end
