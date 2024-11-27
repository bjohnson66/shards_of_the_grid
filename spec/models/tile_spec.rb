require 'rails_helper'

RSpec.describe Tile, type: :model do
  describe 'Associations' do
    it 'belongs to game' do
      assoc = Tile.reflect_on_association(:game)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'has many game_users' do
      assoc = Tile.reflect_on_association(:game_users)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:foreign_key]).to eq 'current_tile_id'
    end
  end

  describe 'Validations' do
    let(:game) { create(:game, name: "Test Game", join_code: "ABC123") }
    let(:valid_attributes) do
      {
        game: game,
        x_coordinate: rand(1..100),
        y_coordinate: rand(1..100),
        tile_type: 'normal'
      }
    end

    it 'is valid with valid attributes' do
      tile = Tile.new(valid_attributes)
      expect(tile).to be_valid
    end

    it 'is not valid without x_coordinate' do
      tile = Tile.new(valid_attributes.except(:x_coordinate))
      expect(tile).not_to be_valid
      expect(tile.errors[:x_coordinate]).to include("can't be blank")
    end

    it 'is not valid without y_coordinate' do
      tile = Tile.new(valid_attributes.except(:y_coordinate))
      expect(tile).not_to be_valid
      expect(tile.errors[:y_coordinate]).to include("can't be blank")
    end

    it 'is not valid without tile_type' do
      tile = Tile.new(valid_attributes.except(:tile_type))
      expect(tile).not_to be_valid
      expect(tile.errors[:tile_type]).to include("can't be blank")
    end

    it 'is not valid with non-integer x_coordinate' do
      tile = Tile.new(valid_attributes.merge(x_coordinate: 1.5))
      expect(tile).not_to be_valid
      expect(tile.errors[:x_coordinate]).to include("must be an integer")
    end

    it 'is not valid with non-integer y_coordinate' do
      tile = Tile.new(valid_attributes.merge(y_coordinate: 1.5))
      expect(tile).not_to be_valid
      expect(tile.errors[:y_coordinate]).to include("must be an integer")
    end

    it 'is not valid without a game' do
      tile = Tile.new(valid_attributes.except(:game))
      expect(tile).not_to be_valid
      expect(tile.errors[:game]).to include("must exist")
    end

    context 'coordinate uniqueness' do
      it 'enforces unique coordinates within a game' do
        tile1 = Tile.create!(valid_attributes)
        tile2 = Tile.new(
          game: game,
          x_coordinate: tile1.x_coordinate,
          y_coordinate: tile1.y_coordinate,
          tile_type: 'normal'
        )
        expect(tile2).not_to be_valid
        expect(tile2.errors[:x_coordinate]).to include("and Y coordinate combination must be unique within a game")
      end

      it 'allows same coordinates in different games' do
        tile1 = Tile.create!(valid_attributes)
        game2 = create(:game, name: "Other Game", join_code: "XYZ789")
        tile2 = Tile.new(
          game: game2,
          x_coordinate: tile1.x_coordinate,
          y_coordinate: tile1.y_coordinate,
          tile_type: 'normal'
        )
        expect(tile2).to be_valid
      end
    end
  end
end