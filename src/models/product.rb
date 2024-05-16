module Product
  def self.all
    db.execute ('SELECT * FROM products')
  end

  def self.find(id) 
    db.execute('SELECT * FROM products WHERE id = ?', id).first
  end

  def self.with_tag(tag)
    db.execute('SELECT products.id, products.name, products.description, products.price, products.image_path FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id WHERE tags.tag_name = ?', tag)
  end

  def self.create(name, description, price, image_path)
    db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?) RETURNING *', name, description, price, image_path).first
  end

  def self.delete(id)
    db.execute('DELETE FROM products WHERE id = ?', id)
  end

  def self.update_with_image(name, description, price, image_path, id)
    db.execute('UPDATE products SET name = ?, description = ?, price= ?, image_path = ? WHERE id = ? RETURNING *', name, description, price, image_path, id).first
  end

  def self.update(name, description, price, id)
    db.execute('UPDATE products SET name = ?, description = ?, price= ? WHERE id = ? RETURNING *', name, description, price, id).first
  end


  def self.db 
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
        return @db
  end
end
