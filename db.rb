require 'sqlite3'

# Open a SQLite 3 database file
db = SQLite3::Database.new 'wimdu.db'

# Create a table
result = db.execute <<-SQL
CREATE TABLE flats (
  id VARCHAR(30),
  title VARCHAR(50),
  propertyType VARCHAR(30),
  address TEXT,
  nightlyRate VARCHAR(30),
  maxGuests VARCHAR(30),
  phone VARCHAR(30),
  email VARCHAR(30)
);
SQL

db.execute "INSERT INTO flats VALUES('pqnaxhhm','sfsadf','2', 'sfasf',
    	34, 4, 'dgd@fg.vf', '435352')"

# Find some records
db.execute 'SELECT * FROM flats' do |row|
  p row
end
