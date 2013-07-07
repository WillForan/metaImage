package vone;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use Dancer::Plugin::Ajax;
use JSON::XS;
use Data::Dumper;
use exifParse;

our $VERSION = '0.1';

get '/test' => sub {template 'edittest' };
post '/test' => sub {
     debug(Dumper(params));
     template 'edittest',{  Test=> params->{testc} }
};



######### LOGIN #########

## notes
get '/' => sub {
  open my $file, '<', 'world-notes.txt';
  my @lines=<$file>;
  my $lines=join("",@lines);
  close $file;
  use Text::Markdown 'markdown';
  my $html = markdown($lines) .
   "<br><a href='/?edit=T'>edit</a>" ;
  return $html unless param('edit');
  return <<EOFHTML
   <form method="post" action="/">
    <textarea style="height:90%;width:100%" name="text">$lines</textarea>
    <input type=submit />
   </form>
EOFHTML
};
post '/' => sub {
  open my $file, '>', 'world-notes.txt';
  print $file param('text');
  close $file;
  redirect("/");
};

#hook 'before' => sub {
# request->path_info() ne "/" && ! session->{'uname'} && redirect('/login');
#};

get '/login' => sub {
    template 'login',{fail=>params->{fail}};
};
post '/login' => sub {
    ## TODO: openid
    my $id   = mongo->get_database('stv1')->get_collection('Peps')->find_one({Email=> params->{Email}});
    
    redirect('/login?fail=uname') unless $id;
    # clearner way to do this?
    session Name => $id->{Name};
    session Email => $id->{Email};
    session BYear => $id->{Byearl};
    redirect('/explore');
    # user exists, check passwor
    ## login and redirect
    ## or give another chance
    # User email doesn't exist
    ## if parm create
    # add
    ## else
    # prompt to create
};

# no security! 
get '/login/:name' => sub {
 session Name => params->{Name};
 session Location => 'Pittsburgh';
 redirect('/explore');
};

get '/logout' => sub {
  session->destroy;
  redirect('/explore');
};

######### Peps managemnt

ajax '/add/person' => sub {
   return {response=>"you've given me a bad query",success=>0} unless param('Email') and param('Name');
   my $exists =  mongo->get_database('stv1')->get_collection('Peps')->find_one({Email=> param('Email') });
   return {response=>param('Email') . " is already accounted for",success=>0} if $exists;

   my %pep;
   for my $key (qw/Name Email YOB Tags/){
       next unless param($key); 
       # do better checking here!
       $pep{$key}=param($key);	
   }

   #insert
   my $inserted =  mongo->get_database('stv1')->get_collection('Peps')->insert(\%pep);
   return {response=>"database error: insert failure",success=>0} unless $inserted;
   return {response=>"success",success=>1};

};


######### Image managemnt
### TODO: dry code
### Uploading
get '/upload' => sub {
    
    my $picCol   = mongo->get_database('stv1')->get_collection('Pics');
    my @unfinished = $picCol->find({Email=> session->{Email},Longitude=> undef })->all();

    # if name is owner
    template 'upload', {pics=>\@unfinished};
    # othwerwise go to image view
    #template 'view', {pics=>\@pics};
};
post '/upload' => sub {
 my @files = upload('files');
 #return join("\n", map {$_->tempname} @files);
 
 my @returnhash;
 for my $file (@files) {
  push @returnhash, exifParse::addPic($file->tempname,
                    'vone/public/images/byhash',
                    mongo->get_database('stv1')->get_collection('Pics')
                   );
 }

 #return "@returnhash";
 my $picCol   = mongo->get_database('stv1')->get_collection('Pics');
 my @unfinished = $picCol->find({Email=> session->{Email},Longitude=> undef })->all();
 my @uploaded  = $picCol->find({md5sum => {'$in' => \@returnhash} })->all();


 template 'upload', {pics=>\@unfinished, newuploads=>\@uploaded};

};

### Editing

# view single image
get '/image/:hash' => sub {
    my $hash = param('hash');
    my @pics   = mongo->get_database('stv1')->get_collection('Pics')->find({md5sum => "$hash"})->all();

    # if name is owner
    template 'edit', {pics=>\@pics};
    # othwerwise go to image view
    #template 'view', {pics=>\@pics};
};

# json like [ {Name: 'Blah', Email: .., x: , y: }, ..]
ajax '/image/:hash/Peps' => sub{
 my $hash = param('hash');
 # this shouldn't be an array
 my $picCol   = mongo->get_database('stv1')->get_collection('Pics');
 my $pic   = $picCol->find_one({md5sum => $hash});
 return {success=>0,response=>'no image with that hash'} unless $pic;

 my $json = request->body;
 my $peps = decode_json $json;
 debug($pic);
 debug($hash);
 debug($peps);

 my $success = $picCol->find_and_modify({query=>{ md5sum => $hash}, update=>{'$set'=>{Peps => $peps  }} });

 return {success=>0,response=>'db update failed'} unless $success;

 return {success=>1,response=>'update'};
};

# edit single image
ajax  '/tags' => sub{
 my @tags= map {param('term').$_} qw(foo bar blas);
 return \@tags;
};

ajax  '/people' => sub{
 my $term=param('term');
 #my @peps= mongo->get_database('stv1')->get_collection('Peps')->find({'Name' => qr/$term/i })->all();
 #@peps=map {$_->{'Name'} } @peps;
 #debug(Dumper(@peps));
 my @peps=grep {$_->{'label'} =~ /$term/i} ( 
      {label=>'Will', value=>'willforan@gmail.com'},
      {label=>'Emily',value=>'emilymente@gmail.com'},
      {label=>'Alex' ,value=>'alexep@bad.c'} );
 return \@peps ;
};


post '/image/:hash' => sub {
    ## TODO: CHECK OWNER

    my $hash = param('hash');
    my $Pics = mongo->get_database('stv1')->get_collection('Pics');
    # this shouldn't be an array
    my @pics   = $Pics->find({md5sum => "$hash"})->all();
    # update pic

    # possible things we could be updating
    # could save time using just parms, but this way prevents injects?
    for my $p (qw/Latitude Longitude Tags Event Peps/) {
        my $value = params->{$p} || next;
	$value = [ split(',',$value) ] if($p =~ /Tags|Peps/);
	#TODO: positions if p is Peps
	$Pics->find_and_modify({query=>{md5sum => $hash},update=>{'$set'=>{$p=>$value}}});
    }

    @pics   = $Pics->find({md5sum  => "$hash"})->all();

    # if ajax, return @pics

    template 'edit', {pics=>\@pics};
};

get '/explore' => sub {
    my @peps   = mongo->get_database('stv1')->get_collection('Peps')->find()->all();
    my @pics   = mongo->get_database('stv1')->get_collection('Pics')->find()->all();
    my @events = mongo->get_database('stv1')->get_collection('Events')->find()->all();

    template 'explore', { location => 'Pittsburgh', name=> session->{Name}||'AC',
	                  pics => \@pics, peps=>\@peps, events=>\@events };
};
#
# explore: Tags or Name 
#
get '/explore/:type/:value' => sub {
    my $type=param('type');
    my $value=param('value');
    redirect('/explore') unless $type =~ m/^(Tags|Name)$/;

    my $db=mongo->get_database('stv1');
    my @peps   = $db->get_collection('Peps')->find(  {$type => "$value"})->all();
    my @pics   = $db->get_collection('Pics')->find(  {$type => "$value"})->all();
    my @events = $db->get_collection('Events')->find({$type => "$value"})->all();

    template 'explore', { location => session->{Location} , name=> session->{Name}||'AC',
	                  pics => \@pics, peps=>\@peps, events=>\@events };
};


true;
