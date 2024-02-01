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
        erb :'products/products'
    end

    get '/products/:id' do |id|
        @product = db.execute('SELECT * FROM products WHERE id = ?', params[:id]).first
        erb :'products/product_view'
    end
    
end