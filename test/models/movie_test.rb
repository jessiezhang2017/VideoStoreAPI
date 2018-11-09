require "test_helper"

describe Movie do
  describe "validations" do
    it "must have a title" do
      movie = movies(:taken)

      movie.title = nil
      result = movie.save
      result.must_equal false

      movie.title = "Jane"
      result = movie.save
      result.must_equal true
    end

    it "must have a unique title" do
      movie = movies(:taken)
      movie2 = Movie.new

      movie2.title = "Taken"
      movie2.inventory = 10
      movie2.available_inventory = 10

      result = movie2.save
      result.must_equal false

      movie2.title = "Jane"

      result = movie2.save
      result.must_equal true
    end



    it "must have inventory" do
      movie = movies(:taken)

      movie.inventory = nil
      result = movie.save
      result.must_equal false

      movie.inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "must have 0 or more inventory" do
      movie = movies(:taken)

      movie.inventory =  -1
      result = movie.save
      result.must_equal false

      movie.inventory = 0
      result = movie.save
      result.must_equal true

      movie.inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "inventory must be numerical" do
      movie = movies(:taken)

      movie.inventory =  "t"
      result = movie.save
      result.must_equal false

    end

    it "must have an available inventory" do
      movie = movies(:taken)

      movie.available_inventory = nil
      result = movie.save
      result.must_equal false

      movie.available_inventory = 1
      result = movie.save
      result.must_equal true
    end

    it "must have 0 or more available inventory" do
      movie = movies(:taken)

      movie.available_inventory =  -1
      result = movie.save
      result.must_equal false

      movie.available_inventory = 0
      result = movie.save
      result.must_equal true

      movie.available_inventory = 1
      result = movie.save
      result.must_equal true
    end

    it " available inventory must be numerical" do
      movie = movies(:taken)

      movie.available_inventory =  "t"
      result = movie.save
      result.must_equal false

    end


  end

  describe "relationships" do

    it "has many rentals" do
      movie = movies(:taken)

      movie.must_respond_to :rentals

      movie.rentals.each do |rental|
      rental.movie.must_be_kind_of Movie
      end
    end
  end

 describe "self.sort?" do
   it "return true if parameter is valid " do
     expect(Movie.sort?("title")).must_equal true
     expect(Movie.sort?("release_date")).must_equal true
   end

   it "return false if parameter is not valid" do
     expect(Movie.sort?("")).must_equal false
   end

   it "return false if no parameter" do
     expect(Movie.sort?("test")).must_equal false
   end
 end

 describe "self.checked_out_rentals" do
   before do
     @movie = movies(:taken)
     @rental1 = rentals(:one)
     @rental2 = rentals(:four)

     customers = Movie.checked_out_rentals(@movie)
     @customer_names = []

     customers.each do |cust|
       @customer_names << cust[:customer_name]
     end


   end
   it "return an array " do

     expect(Movie.checked_out_rentals(@movie)).must_be_kind_of Array

   end

   it "return the customer if the rental status is checked out" do
     expect(Movie.checked_out_rentals(@movie).first[:customer_name]).must_equal "Lily"
     expect(@customer_names.include? "Lily").must_equal true
   end

   it "do not return the customer if the rental status is returned" do

     expect(@customer_names.include? "Mike").must_equal false
   end
 end

 describe "self.returned_rentals" do
   before do
     @movie = movies(:taken)
     @rental1 = rentals(:one)
     @rental2 = rentals(:four)

     customers = Movie.returned_rentals(@movie)
     @customer_names = []

     customers.each do |cust|
       @customer_names << cust[:customer_name]
     end


   end
   it "return an array " do

     expect(Movie.returned_rentals(@movie)).must_be_kind_of Array

   end

   it "return the customer if the rental status is renturned" do
     expect(Movie.returned_rentals(@movie).first[:customer_name]).must_equal "Mike"
     expect(@customer_names.include? "Mike").must_equal true
   end

   it "do not return the customer if the rental status is checked out" do

     expect(@customer_names.include? "Lily").must_equal false
   end
 end

end
