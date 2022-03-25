class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil,name:,breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
            SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
        DB[:conn].execute(sql,[self.name,self.breed])
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:,breed:,id:nil)
        pup = Dog.new(name:name,breed:breed,id:id)
        pup.save
    end

    def self.new_from_db(row)
        Dog.new(id:row[0],name:row[1],breed:row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            SQL
        pup = DB[:conn].execute(sql,[id]).first
        dog = Dog.new(id:pup[0],name:pup[1],breed:pup[2])
        dog
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            SQL
        pup = DB[:conn].execute(sql,[name,breed])
        if !pup.empty?
            dog = pup[0]
            h = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
            h
        else
            dog = Dog.create(name:name,breed:breed)
            dog
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            SQL
        pup = DB[:conn].execute(sql,[name]).first
        dog = Dog.new(id:pup[0],name:pup[1],breed:pup[2])
        dog
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
            SQL
        DB[:conn].execute(sql,[self.name,self.breed,self.id])
    end
    
end
