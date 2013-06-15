//db = connect("localhost:27020/stv1");
db.dropDatabase()

//Names are unique and required
db.Peps.ensureIndex(  {Name: 1},{ unique: true, sparse: true} )
db.Peps.insert( {Name: 'Will',  Byear: 1986, Email: 'willforan@gmail.com' } )
db.Peps.insert( {Name: 'Emily', Byear: 1988, Email: 'emilymente@gmail.com'} )

db.Tags.ensureIndex(  {Name: 1},{ unique: true, sparse: true} )
db.Tags.insert(   [ {Name: 'fun', Type: 'attr'}, {Name: 'abandoned', Type: 'attr'} ])

db.Locs.insert(   {Name: 'Warlock Query'} )
db.Locs.insert(   {Name: 'Warlock Query'} )


db.Events.insert( {Name: 'Journey to Warlock Query'} )
