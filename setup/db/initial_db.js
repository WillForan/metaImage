//db = connect("localhost/stv1");
// launch with mongo localhost/stv1 initial_db.js
db.dropDatabase()

//Names are unique and required
db.Peps.ensureIndex(  {Name: 1},{ unique: true, sparse: true} )
db.Peps.insert(  [
        {Name: 'Emily', Byear: 1988, Email: 'emilymente@gmail.com', Tags: ['gal'] },
	{Name: 'Will',  Byear: 1986, Email: 'willforan@gmail.com',  Tags: ['guy'] }
])


/* *** Tags collection is useless? *** */
// Tags, applied to everything -- may not be useful here?
db.Tags.ensureIndex(  {Name: 1},{ unique: true, sparse: true} )
db.Tags.insert(   [ {Name: 'code-monkey'},
	            {Name: 'fun'},
	            {Name: 'abandoned'},
	            {Name: 'running'},
	            {Name: 'family'},
	            {Name: 'guy', Aliases: ['male','dude','bro','man']},
	            {Name: 'gal', Aliases: ['female','girl','chick','woman']},
	            {Name: 'race'},
	            {Name: 'trail'},
	            {Name: 'oil'},
	            {Name: 'snow'},
	            {Name: 'quary'} ])

// Places 
db.Locs.insert(   [ 
	{Name: 'Warlock Quary'},
	{Name: 'Horse Crick'}
	] )


// Pics and Events, partical genration from ../images/imagesToJson.bash

db.Events.insert({Name: "PittBoat"})
db.Events.insert({Name: "NiagraFalls"})
db.Events.insert({Name: "WarlockQuary",Peps: ['willforan@gmail.com','emilytmente@gmail.com']})
db.Events.insert({Name: "OilCityEaster"})
db.Events.insert({Name: "NateRace"})

db.Pics.insert([ 
 { 
	Height: 960,
	File: "NateRace/0608131017a.jpg",
	Event: "NateRace",
	Hash: "b58c6e81ef2434dc479bfcca68dabec1",
        Owner: 'willforan@gmail.com',
	Width: 1280
 },
 { 
	File: "NiagraFalls/0607132039.jpg",
	Hash: "adb9982df1d28ba24795185cd26e9465",
	Event: "NiagraFalls",
        Owner: 'willforan@gmail.com',
	Width: 1280,
	Height: 960
 },
 { 
	Height: 960,
	Width: 1280,
	Event: "NiagraFalls",
	Hash: "ce3b0359811bfef06fa49714978af76d",
        Owner: 'willforan@gmail.com',
	File: "NiagraFalls/0607132047.jpg"
 },
 { 
	File: "NiagraFalls/0607132051.jpg",
	Height: 960,
	Width: 1280,
	Event: "NiagraFalls",
        Owner: 'willforan@gmail.com',
	Hash: "e2eaf224d83d6813583482a986c80c83"
 },
 { 
	Hash: "f140cd8ac21494b0b36d0f2662a0e6f2",
	Event: "OilCityEaster",
	Height: 960,
	Width: 1280,
	Longitude: 79.688467,
	Time: 112151,
	File: "OilCityEaster/0331131121.jpg",
	Date: "2013-03-31T11:21:51",
	Latitude: 41.441811,
        Owner: 'willforan@gmail.com',
	Peps: [{Email: 'willforan@gmail.com', x: 1, y:1, r:10} ],
	Tags: ['family']
 },
 { 
	Time: 115344,
	Latitude: 41.429978,
	Width: 1280,
	Longitude: 79.658433,
	Date: "2013-03-31T11:53:44",
	Hash: "cde50ef920f4b5bcb6e2b35e1a00d5b7",
	Event: "OilCityEaster",
	File: "OilCityEaster/0331131153b.jpg",
        Owner: 'willforan@gmail.com',
	Height: 960,
	Tags: ['family']
 },
 { 
	Event: "OilCityEaster",
	Latitude: 41.430886,
	File: "OilCityEaster/0331131249.jpg",
	Date: "2013-03-31T12:49:09",
	Time: 124909,
	Height: 960,
	Width: 1280,
	Hash: "f4e0a0cd587999c0a5504b618a9c4c5f",
        Owner: 'willforan@gmail.com',
	Longitude: 79.661686,
	Tags: ['family']
 },
 { 
	File: "PittBoat/0531131945.jpg",
	Hash: "6f28198117e129e2e7f4e458d7e7c851",
	Event: "PittBoat",
        Owner: 'willforan@gmail.com',
	Height: 1280,
	Width: 960
 },
 { 
	File: "PittBoat/0531131955.jpg",
	Height: 960,
	Event: "PittBoat",
	Width: 1280,
	Hash: "73e6c23348dd0af7f81786ef583c49db"
 },
 { 
	File: "PittBoat/0531132011a.jpg",
	Height: 960,
	Event: "PittBoat",
	Width: 1280,
        Owner: 'willforan@gmail.com',
	Hash: "3d5d4fee2aa053c96b58583674babbcd"
 },
 { 
	Event: "PittBoat",
	Width: 1280,
	Height: 960,
	Hash: "a929c14c136c680f6c75b72d77721204",
        Owner: 'willforan@gmail.com',
	File: "PittBoat/0531132016b.jpg"
 },
 { 
	Width: 960,
	File: "WarlockQuary/0609131111b.jpg",
	Event: "WarlockQuary",
        Owner: 'willforan@gmail.com',
	Hash: "cd3abeda0cbcca9a8ac4c60f4174a5c3",
	Height: 1280
 },
 { 
	Width: 1280,
	Hash: "f8e0ac8a581cad51e987215f2927e830",
	File: "WarlockQuary/0609131113.jpg",
        Owner: 'willforan@gmail.com',
	Height: 960,
	Event: "WarlockQuary"
 },
 { 
	Height: 960,
	Hash: "a62e7543465fa9fb26e94258a1e1d798",
	Event: "WarlockQuary",
	File: "WarlockQuary/0609131142a.jpg",
        Owner: 'willforan@gmail.com',
	Width: 1280
 },
 { 
	Height: 1280,
	File: "WarlockQuary/0609131145.jpg",
	Width: 960,
	Event: "WarlockQuary",
        Owner: 'willforan@gmail.com',
	Hash: "8a95bf8800ebc92a65434f2e901e3f3c"
 },
 { 
	Event: "WarlockQuary",
	Width: 960,
	Date: "2013-06-09T11:50:48",
	Hash: "77167eaed3145f81caeb367b469b2045",
	Height: 1280,
	File: "WarlockQuary/0609131150.jpg",
        Owner: 'emilymente@gmail.com',
	Time: 115048
 },
 { 
	Height: 960,
	File: "WarlockQuary/0609131151.jpg",
	Hash: "aab45fa5751bd2f1cb76b273f49f4ff8",
	Width: 1280,
        Owner: 'emilymente@gmail.com',
	Event: "WarlockQuary"
 }
 ] )
