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
        erb :'products/view'
    end

    post '/products/create' do
        result = db.execute('INSERT INTO products (name, description, price) VALUES (?, ?, ?) RETURNING *', params[:name], params[:description], params[:price]).first
        redirect "/products/#{result["id"]}"
    end

    post '/products/:id/delete' do |id|
        db.execute('DELETE FROM products WHERE id = ?', id)
        redirect "/products"
    end
    
end