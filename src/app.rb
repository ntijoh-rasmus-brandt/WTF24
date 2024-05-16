require_relative 'models/product'
require_relative 'models/tag'
require_relative 'models/review'
require_relative 'models/user'


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
        if @user_id != nil
            @user_access = db.execute('SELECT access FROM users WHERE id = ?', @user_id).first['access']
        end
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
            @products = Product.all
        else
            @products = Product.with_tag(tag)
        end
        @tags = Tag.all
        erb :'products/index'
    end

    get '/products/new' do
        erb :'products/new'
    end 
    
    get '/products/:id' do |id|
        @product = Product.find(id)
        @reviews = Review.for_product(id)
        @product_tags = Tag.on_product(id)
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
            @product = Product.find(id)
            erb :'products/delete'
        end
    end

    get '/products/:id/edit' do |id|
        if @user_access != 2
            redirect "/"
        else
            @product = Product.find(id)
            @tags = Tag.all
            @product_tags = Tag.on_product(id)
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

            result = Product.create(params[:name], params[:description], params[:price], file_path)
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
            product = Product.find(id)
            File.delete(product['image_path'])
            Product.delete(id)
            redirect "/products"
        end
    end

    post '/products/:id/update/delete_tag/:tag_id' do |product_id, tag_id|
        if @user_access != 2
            redirect "/"
        else
            Tag.delete(product_id, tag_id)
            redirect "/products/#{product_id}/edit"
        end
    end

    post '/products/:id/update/add_tag' do |product_id|
        if @user_access != 2
            redirect "/"
        else
            tag_id = params[:tag_select]
            exists = Tag.exists_on_product(product_id, tag_id)
            if exists.empty?
                Tag.add_on_product(product_id, tag_id)
            end
            redirect "/products/#{product_id}/edit"
        end
    end

    post '/products/:id/update' do |id|
        if @user_access != 2
            redirect "/"
        else
            if params[:file] != nil
                product = Product.find(id)
                File.delete(product['image_path'])
                
                file_name = SecureRandom.alphanumeric(16)
                file = params[:file][:tempfile]
                file_path = "img/product/#{file_name}.jpg"

                File.open("public/#{file_path}", 'wb') do |f|
                    f.write(file.read)
                end

                result = Product.update_with_image(params[:name], params[:description], params[:price], file_path, id)
            else
                result = Product.update(params[:name], params[:description], params[:price], id)
            end
            redirect "/products/#{result['id']}"
        end
    end

    post '/review/:id/create' do |id|
        result = Review.create(params[:rating], h(params[:review]))
        Review.link_product(id, result['id'])
        Review.link_user(@user_id, result['id'])
        redirect "/products/#{id}"
    end

    get '/reviews/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            @review = Review.find(id)
            erb :'reviews/delete'
        end
    end

    post '/reviews/:id/delete' do |id|
        if @user_access != 2
            redirect "/"
        else
            product_id = Review.product_id(id)
            Review.delete_product_link(id)
            Review.delete(id)
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
        exists = User.find_username(params[:username])
        if exists.empty?
            hashed_password = BCrypt::Password.create(params[:password])
            User.create(h(params[:username]), hashed_password, 1)
            redirect '/users/login'
        else
            redirect '/users/register'
        end

    end

    post '/users/login' do
        user = User.find_username(h(params[:username])).first
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