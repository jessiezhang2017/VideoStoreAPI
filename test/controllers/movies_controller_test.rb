require "test_helper"

describe MoviesController do

  it "is a real working route and returns JSON" do
      # Act
      get movies_path

      # Assert
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :success
  end

  it "returns an Array" do
  # Act
  get movies_path

  # Convert the JSON response into a Hash
  body = JSON.parse(response.body)

  # Assert
  expect(body).must_be_kind_of Array
end

it "returns all of the movies" do
  # Act
  get movies_path

  # Convert the JSON response into a Hash
  body = JSON.parse(response.body)

  # Assert
  expect(body.length).must_equal Movie.count
end

it "returns moviess with exactly the required fields" do
  keys = %w(id title release_date)

  # Act
  get movies_path

  # Convert the JSON response into a Hash
  body = JSON.parse(response.body)

  # Assert that each
  body.each do |movie|
    expect(movie.keys).must_equal keys
    expect(movie.keys.length).must_equal keys.length
  end
 end
end
