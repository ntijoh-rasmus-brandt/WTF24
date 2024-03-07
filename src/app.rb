class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        erb :index
    end

    get '/products' do 
        @products = db.execute('SELECT * FROM products')
        erb :'products/index'
    end

    get '/products/new' do
        erb :'products/new'
    end 
    
    get '/products/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        @reviews = db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id WHERE products.id = ?', id)
        sum_ratings = 0
        amount = 0.0
        @reviews.each do |review|
            sum_ratings += review['rating']
            amount += 1
        end
        if (amount == 0)
            @rating = "Be the first the review!"
        else
            @rating = "#{(sum_ratings/amount).round(2)}/5" 
        end
        erb :'products/show'
    end

    get '/products/:id/delete' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        erb :'products/delete'
    end

    get '/products/:id/edit' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        erb :'products/edit'
    end

    post '/products/create' do
        file_name = params[:file][:filename]
        file = params[:file][:tempfile]
        file_path = "img/product/#{file_name}"

        File.open("public/#{file_path}", 'wb') do |f|
            f.write(file.read)
        end

        result = db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?) RETURNING *', params[:name], params[:description], params[:price], file_path).first
        redirect "/products/#{result["id"]}"
    end

    post '/products/review/:id' do |id|
        result = db.execute('INSERT INTO reviews (rating, review) VALUES (?, ?) RETURNING *', params[:rating], params[:review]).first
        db.execute('INSERT INTO product_reviews (product_id, review_id) VALUES (?, ?)', id, result['id'])
        redirect "/products/#{id}"
    end

    post '/products/:id/delete' do |id|
        db.execute('DELETE FROM products WHERE id = ?', id)
        redirect "/products"
    end

    post '/products/:id/update' do |id|
        if params[:file] != nil
            product = db.execute('SELECT FROM products WHERE id = ?', id)
            File.delete(product['image_path'])
            
            file_name = params[:file][:filename]
            file = params[:file][:tempfile]
            file_path = "img/product/#{file_name}"

            File.open("public/#{file_path}", 'wb') do |f|
                f.write(file.read)
            end

            result = db.execute('UPDATE products SET name = ?, description = ?, price= ?, image_path = ? WHERE id = ? RETURNING *', params[:name], params[:description], params[:price], file_path, id).first
        else
            result = db.execute('UPDATE products SET name = ?, description = ?, price= ? WHERE id = ? RETURNING *', params[:name], params[:description], params[:price], id).first
        end
        redirect "/products/#{result['id']}"
    end

    get '/reviews/:id/delete' do |id|
        @review = db.execute('SELECT * FROM reviews WHERE id = ?', id).first
        erb :'reviews/delete'
    end

    post '/reviews/:id/delete' do |id|
        product_id = db.execute('SELECT * FROM product_reviews WHERE review_id = ?', id).first['product_id']
        db.execute('DELETE FROM product_reviews WHERE review_id = ?', id)
        db.execute('DELETE FROM reviews WHERE id  = ?', id)
        redirect "/products/#{product_id}"
    end
    
end