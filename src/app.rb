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

    get '/products/create' do
        erb :'products/create'
    end 

    get '/products/:id/delete' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        erb :'products/delete'
    end
    
    get '/products/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        @reviews = db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id WHERE products.id = ?', id)
        erb :'products/show'
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
    
end