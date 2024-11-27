class Game < ApplicationRecord
  belongs_to :current_turn_user, class_name: 'User', foreign_key: 'current_turn_user_id', optional: true
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id', optional: true

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
  has_many :tiles, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :join_code,
            format: {
              with: /\A[A-Z0-9]{6}\z/,
              message: "must be 6 uppercase alphanumeric characters"
            },
            uniqueness: true,
            presence: true
  validates :map_size, presence: true
  validate :validate_map_size_format_and_minimum

  # Callbacks
  after_validation :normalize_join_code
  after_create :generate_tiles

  private

  def normalize_join_code
    self.join_code = join_code.upcase.strip if join_code.present?
  end

  def validate_map_size_format_and_minimum
    return if map_size.blank?

    unless map_size.match?(/^\d+x\d+$/)
      errors.add(:map_size, "must be in the format 'NxM' (e.g., '6x6')")
      return
    end

    rows, columns = map_size.split('x').map(&:to_i)
    if rows < 6 || columns < 6
      errors.add(:map_size, "must be at least 6x6")
    end
  end

  def generate_tiles
    rows, columns = map_size.split('x').map(&:to_i)
    (1..rows).each do |x|
      (1..columns).each do |y|
        tiles.create!(
          x_coordinate: x,
          y_coordinate: y,
          tile_type: default_tile_type
        )
      end
    end
  end

  def default_tile_type
    'grassland' # You can customize this method to assign different tile types
  end
end
