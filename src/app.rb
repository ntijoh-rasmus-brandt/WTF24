class App < Sinatra::Base

    enable :sessions

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    helpers do
        def h(text)
            Rack::Utils.escape_html(text)
        end
    end

    before do
        @user_id = session[:user_id]
        @user_access = db.execute('SELECT access FROM users WHERE id = ?', @user_id).first
    end

    get '/' do
        redirect "/products/tag/All"
    end

    get '/products' do 
        redirect "/products/tag/All"
    end

    get '/products/tag/:tag' do |tag|
        # binding.break
        if tag == "All"
            @products = db.execute ('SELECT * FROM products')
        else
            @products = db.execute('SELECT products.id, products.name, products.description, products.price, products.image_path FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON product_tags.product_id = products.id WHERE tags.tag_name = ?', tag)
        end
        @tags = db.execute('SELECT * FROM tags')
        erb :'products/index'
    end

    get '/products/new' do
        erb :'products/new'
    end 
    
    get '/products/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
        @reviews = db.execute('SELECT * FROM reviews INNER JOIN product_reviews ON reviews.id = product_reviews.review_id INNER JOIN products ON product_reviews.product_id = products.id INNER JOIN user_reviews ON product_reviews.review_id = user_reviews.review_id INNER JOIN users ON user_reviews.user_id = users.id WHERE products.id = ?', id)
        @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON products.id = product_tags.product_id WHERE products.id = ?', id)
        sum_ratings = 0
        amount = 0.0
        @reviews.each do |review|
            sum_ratings += review['rating']
            amount += 1
        end
        if (amount == 0)
            @rating = "Be the first to review!"
        else
            @rating = "#{(sum_ratings/amount).round(2)}/5" 
        end
        erb :'products/show'
    end

    get '/products/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
            erb :'products/delete'
        end
    end

    get '/products/:id/edit' do |id|
        if @user_access != 2
            redirect "/"
        else
            @product = db.execute('SELECT * FROM products WHERE id = ?', id).first
            @tags = db.execute('SELECT * FROM tags')
            @product_tags = db.execute('SELECT * FROM tags INNER JOIN product_tags ON tags.id = product_tags.tag_id INNER JOIN products ON products.id = product_tags.product_id WHERE products.id = ?', id)
            erb :'products/edit'
        end
    end

    post '/products/create' do
        if @user_access != 2
            redirect "/"
        else
            file = params[:file][:tempfile]
            file_name = SecureRandom.alphanumeric(16)
            file_path = "img/product/#{file_name}.jpg"

            File.open("public/#{file_path}", 'wb') do |f|
                f.write(file.read)
            end

            result = db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?, ?, ?, ?) RETURNING *', params[:name], params[:description], params[:price], file_path).first
            redirect "/products/#{result["id"]}"
        end
    end

    post '/products/tags' do
        tag = params[:tags]
        redirect "/products/tag/#{tag}"
    end

    post '/products/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            product = db.execute('SELECT FROM products WHERE id = ?', id)
            File.delete(product['image_path'])
            db.execute('DELETE FROM products WHERE id = ?', id)
            redirect "/products"
        end
    end

    post '/products/:id/update/delete_tag/:tag_id' do |product_id, tag_id|
        if @user_access != 2
            redirect "/"
        else
            db.execute('DELETE FROM product_tags WHERE product_id = ? AND tag_id = ?', product_id, tag_id)
            redirect "/products/#{product_id}/edit"
        end
    end

    post '/products/:id/update/add_tag' do |product_id|
        if @user_access != 2
            redirect "/"
        else
            tag_id = params[:tag_select]
            exists = db.execute('SELECT * FROM product_tags WHERE product_id = ? AND tag_id = ?', product_id, tag_id)
            if exists.empty?
                db.execute('INSERT INTO product_tags (product_id, tag_id) VALUES (?, ?)', product_id, tag_id)
            end
            redirect "/products/#{product_id}/edit"
        end
    end

    post '/products/:id/update' do |id|
        if @user_access != 2
            redirect "/"
        else
            if params[:file] != nil
                product = db.execute('SELECT FROM products WHERE id = ?', id)
                File.delete(product['image_path'])
                
                file_name = SecureRandom.alphanumeric(16)
                file = params[:file][:tempfile]
                file_path = "img/product/#{file_name}.jpg"

                File.open("public/#{file_path}", 'wb') do |f|
                    f.write(file.read)
                end

                result = db.execute('UPDATE products SET name = ?, description = ?, price= ?, image_path = ? WHERE id = ? RETURNING *', params[:name], params[:description], params[:price], file_path, id).first
            else
                result = db.execute('UPDATE products SET name = ?, description = ?, price= ? WHERE id = ? RETURNING *', params[:name], params[:description], params[:price], id).first
            end
            redirect "/products/#{result['id']}"
        end
    end

    post '/review/:id/create' do |id|
        result = db.execute('INSERT INTO reviews (rating, review) VALUES (?, ?) RETURNING *', params[:rating], h(params[:review])).first
        db.execute('INSERT INTO product_reviews (product_id, review_id) VALUES (?, ?)', id, result['id'])
        db.execute('INSERT INTO user_reviews (user_id, review_id) VALUES (?, ?)', @user_id, result['id'])
        redirect "/products/#{id}"
    end

    get '/reviews/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            @review = db.execute('SELECT * FROM reviews WHERE id = ?', id).first
            erb :'reviews/delete'
        end
    end

    post '/reviews/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            product_id = db.execute('SELECT * FROM product_reviews WHERE review_id = ?', id).first['product_id']
            db.execute('DELETE FROM product_reviews WHERE review_id = ?', id)
            db.execute('DELETE FROM reviews WHERE id  = ?', id)
            redirect "/products/#{product_id}"
        end
    end

    get '/users/register' do
        if session[:user_id] == nil
            erb :'users/register'
        else
            redirect '/'
        end
    end

    get '/users/login' do
        if session[:user_id] == nil
            erb :'users/login'
        else
            redirect '/'
        end
    end

    get '/users/logout' do
        if session[:user_id] != nil
            erb :'users/logout'
        else
            redirect '/'
        end
    end

    post '/users/register' do
        exists = db.execute('SELECT * FROM users WHERE username = ?', params[:username])
        if exists.empty?
            hashed_password = BCrypt::Password.create(params[:password])
            db.execute('INSERT INTO users (username, password, access) VALUES (?,?,?)', params[:username], hashed_password, 1)
            redirect '/users/login'
        else
            redirect '/users/register'
        end

    end

    post '/users/login' do
        user = db.execute('SELECT * FROM users WHERE username = ?', params[:username]).first
        password_from_db = BCrypt::Password.new(user['password'])
        if password_from_db == params[:password]
            session[:user_id] = user['id']
            redirect '/products/1'
        else
            redirect '/products/2'
        end
    end

    post '/users/logout' do
        session.destroy
        redirect '/'
    end
    
end 