require "thor"
require 'sqlite3'

class Wimdu < Thor
  @db = nil
  def initialize(*args)
    super
    @db = SQLite3::Database.new 'wimdu.db'
  end

  no_commands{
    def property_type(option)
      case option.to_i
      when 1
        "Holiday Home"
      when 2
        "Apartment"
      when 3
        "private room"
      else
        puts "You gave me #{option} -- I have no idea what to do with that."
        nil
      end
    end

  }

  no_commands{
    def numeric?
      return true if self =~ /^\d+$/
    rescue false
    end
  }
  desc "help", "help to execute commands"
  def help
    puts "coming soon!"
  end

  desc "list", "list flats"
  def list
    rows = @db.execute 'SELECT Count(*) FROM flats'
    unless rows[0][0].nil?
      if rows[0][0].eql? 0
        say('No offers found.')
      else
        say("found #{rows[0][0]} offers\n")
        @db.execute 'SELECT * FROM flats' do |row|
          say("#{row[0]} - #{row[1]}")
        end
      end # if-else
    end
  end

  desc "new", "insert a new apartment"
  def new
    # generate random string
    id = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
    say "new apartment - #{id}"

    title = ask("title: ")
    puts "~> #{title}"
    prp_type = ask("property type:\n1. Holiday Home\n2. Apartment\n3. private
    room\n")
    prp_type = property_type(prp_type)
    address = ask("Address: ")
    nightly_rate = ask("Nightly rate: ")
    num_guest = ask("Number of Guests: ")

    unless num_guest =~ /^\d+$/
      loop do
        say "Error: must be a number"
        num_guest = ask("Number of Guests: ")
        break if num_guest =~ /^\d+$/
      end
    end
    email = ask("email: ")
    phone = ask("Phone number: ")
    query = "INSERT INTO flats VALUES('#{id}','#{title}','#{prp_type}', '#{address}',
    	#{nightly_rate}, #{num_guest}, '#{email}', '#{phone}')"

    @db.execute query
    say("Great job! Listing #{id} is complete!")

  rescue SystemExit, Interrupt
    if nightly_rate.eql? nil
      nightly_rate = 0
    end
    if num_guest.eql? nil
      num_guest = 0
    end
    query = "INSERT INTO flats VALUES('#{id}','#{title}','#{prp_type}', '#{address}',#{nightly_rate}, #{num_guest}, '#{email}', '#{phone}')"
    result = @db.execute query
  rescue SQLite3::Exception => e
    say 'Error while inserting data!'
  end

  desc "continue", "edit a flat"
  def continue(id)
    cols = ['id','title','property_type','address','nightly_rate','num_guest','email','phone']
    row = @db.execute "SELECT * FROM flats WHERE id='#{id}'"
    result2 = Hash[cols.zip(row[0])]
    result = result2
    result2.each do |key, value|
      if value.eql? "" or value.eql? 0
        if key.eql? 'propertyType'
          value = ask("property type:\n1. Holiday Home\n2. Apartment\n3. private room")
          value = property_type(value)
        else
          value = ask("Insert #{key}:")
        end
        result[key] = value
      end
    end

    query = "UPDATE flats SET title= '#{result['title']}', propertyType='#{result['property_type']}', address='#{result['address']}',nightlyRate=#{result['nightly_rate']}, maxGuests=#{result['num_guest']}, email='#{result['email']}', phone='#{result['phone']}' WHERE id='#{id}'"

    @db.execute query
    say("Great job! Listing #{id} is complete!")

  rescue SystemExit, Interrupt
    if result['nightly_rate'].eql? nil
      result['nightly_rate'] = 0
    end
    if result['num_guest'].eql? nil
      result['num_guest'] = 0
    end
    query = "UPDATE flats SET title= '#{result['title']}', propertyType='#{result['property_type']}', address='#{result['address']}',nightlyRate=#{result['nightly_rate']}, maxGuests=#{result['num_guest']}, email='#{result['email']}', phone='#{result['phone']}' WHERE id='#{id}'"
    result = @db.execute query
  rescue SQLite3::Exception => e
    say 'Error while updating data!'
  end



end


Wimdu.start

