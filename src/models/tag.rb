module Tag
    def self.all
      db.execute ('SELECT * FROM tags')
    end

    def self.on_product(id)
      db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON products.id = product_tags.product_id WHERE products.id = ?', id)
    end

    def self.delete(product_id, tag_id)
        db.execute('DELETE FROM product_tags WHERE product_id = ? AND tag_id = ?', product_id, tag_id)
    end

    def self.exists_on_product
        db.execute('SELECT * FROM product_tags WHERE product_id = ? AND tag_id = ?', product_id, tag_id)
    end

    def self.add_on_product
        db.execute('INSERT INTO product_tags (product_id, tag_id) VALUES (?, ?)', product_id, tag_id)
    end

    def self.db 
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end
  end
  