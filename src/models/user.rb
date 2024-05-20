module User
    def self.all
      db.execute ('SELECT * FROM users')
    end

    def self.find_username(username)
        db.execute('SELECT * FROM users WHERE username = ?', username)
    end

    def self.create(username, password, access)
        db.execute('INSERT INTO users (username, password, access) VALUES (?,?,?)', username, password, access)
    end

    def self.login_attempt(user_id, successful, date)
        db.execute('INSERT INTO user_login (user_id, successful, date) VALUES (?,?,?)', user_id, successful, date)
    end

    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end
  end
  