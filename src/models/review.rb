module Review
    def self.all
      db.execute ('SELECT * FROM tags')
    end

    def self.find(id) 
      db.execute('SELECT * FROM reviews WHERE id = ?', id).first
    end

    def self.product_id(id)
        db.execute('SELECT product_id FROM product_reviews WHERE review_id = ?', id).first
    end

    def self.for_product(id)
      db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id INNER JOIN user_reviews ON product_reviews.review_id = user_reviews.review_id INNER JOIN users ON user_reviews.user_id = users.id WHERE products.id = ?', id)
    end

    def self.create(rating, review)
        db.execute('INSERT INTO reviews (rating, review) VALUES (?, ?) RETURNING *', params[:rating], h(params[:review])).first
    end

    def self.link_product(product_id, review_id)
        db.execute('INSERT INTO product_reviews (product_id, review_id) VALUES (?, ?)')
    end
    
    def self.link_user(user_id, review_id)
        db.execute('INSERT INTO user_reviews (user_id, review_id) VALUES (?, ?)')
    end

    def self.delete_product_link(id)
        db.execute('DELETE FROM product_reviews WHERE review_id = ?', id)
    end

    def self.delete(id)
        db.execute('DELETE FROM reviews WHERE id  = ?', id)
    end


    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end
  end
  