require 'sqlite3'

def db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def drop_tables
    db.execute('DROP TABLE IF EXISTS products')
    db.execute('DROP TABLE IF EXISTS comments')
    db.execute('DROP TABLE IF EXISTS product_tags')
    db.execute('DROP TABLE IF EXISTS tags')
    db.execute('DROP TABLE IF EXISTS user_comments')
    db.execute('DROP TABLE IF EXISTS users')
end

def create_tables

    db.execute('CREATE TABLE "comments" (
        "id"	INTEGER,
        "value"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    db.execute('CREATE TABLE "product_tags" (
        "product_id"	INTEGER,
        "tag_id"	INTEGER
    )')
    db.execute('CREATE TABLE "products" (
        "id"	INTEGER,
        "name"	TEXT NOT NULL,
        "description"	TEXT,
        "price"	INTEGER,
        "image_path"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    db.execute('CREATE TABLE "tags" (
        "id"	INTEGER,
        "name"	INTEGER NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')
    db.execute('CREATE TABLE "user_comments" (
        "user_id"	INTEGER,
        "comment_id"	INTEGER
    )')
    db.execute('CREATE TABLE "users" (
        "id"	INTEGER,
        "username"	TEXT NOT NULL UNIQUE,
        "password"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    )')

end

def seed_tables

    products = [
        {name: 'Protein Powder', description: ' With sweeteners. Whey protein isolate powder for preparing high protein shakes. Product is designed for athletes and physically active people with a higher demand for proteins. Protein contributes to growth in muscle mass.', price: 199, image_path: 'img/product/protein_powder.jpg'},
        {name: 'Pre Workout', description: 'Food Supplement. With sweeteners. Contains caffeine (200 mg / serving size 8,75 g), not recommended for children or pregnant woman. Pre-workout product recommended for physically active people especially those who engage in high intensity strength training session.', price: 139, image_path: "/img/product/pre_workout.jpg"},
        {name: 'Creatine', description: 'Supplementing the diet with creatine, recommended for adults performing high intensity exercise. Creatine increases physical performance in successive bursts of short-term, high intensity exercise, bene_cial efect is obtained with a daily intake of 3 g of creatine. Vitamin B6 contributes to the normal function of the immune system and also contributes to the reduction of tiredness and fatigue**.', price: 129, image_path: "/img/product/creatine.jpg"},
        {name: 'Protein Bar', description: 'Consume before or after training or as a snack.', price: 18,  image_path: 'img/product/protein_bar.jpg'}
    ]

    products.each do |product|
        db.execute('INSERT INTO products (name, description, price, image_path) VALUES (?,?,?,?)', product[:name], product[:description], product[:price], product[:image_path])
    end

end

drop_tables
create_tables
seed_tables