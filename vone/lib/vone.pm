package vone;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use Data::Dumper;

our $VERSION = '0.1';

hook 'before' => sub {
 request->path_info() ne "/" && ! session->{'uname'} && redirect('/login');
};

get '/' => sub {
    redirect('/explore');
};

get '/login' => sub {
    template 'login';
    # user exists, check password
    ## login and redirect
    ## or give another chance
    # User email doesn't exist
    ## if parm create
    # add
    ## else
    # prompt to create
};

put '/add/:name' => sub {
    my $name    = param('name');
    my $showdow = params->{'shadow'} || 1;
    my $email   = params->{'email'};

};


# view single image
get '/image/:hash' => sub {
    my $hash = param('hash');
    my @pics   = mongo->get_database('stv1')->get_collection('Pics')->find({Hash => "$hash"})->all();

    # if name is owner
    template 'edit', {pics=>\@pics};
    # othwerwise go to image view
    #template 'view', {pics=>\@pics};
};

# edit single image
post '/image/:hash' => sub {
    ## TODO: CHECK OWNER

    my $hash = param('hash');
    my $Pics = mongo->get_database('stv1')->get_collection('Pics');
    # this shouldn't be an array
    my @pics   = $Pics->find({Hash => "$hash"})->all();
    # update pic

    # possible things we could be updating
    # could save time using just parms, but this way prevents injects?
    for my $p (qw/Latitude Longitude Tags Event Peps/) {
        my $value = params->{$p} || next;
	$value = [ split(',',$value) ] if($p =~ /Tags|Peps/);
	#TODO: positions if p is Peps
	$Pics->find_and_modify({query=>{Hash => $hash},update=>{'$set'=>{$p=>$value}}});
    }

    @pics   = $Pics->find({Hash => "$hash"})->all();

    # if ajax, return @pics

    template 'edit', {pics=>\@pics};
};

get '/explore' => sub {
    my @peps   = mongo->get_database('stv1')->get_collection('Peps')->find()->all();
    my @pics   = mongo->get_database('stv1')->get_collection('Pics')->find()->all();
    my @events = mongo->get_database('stv1')->get_collection('Events')->find()->all();

    template 'explore', { location => 'Pittsburgh', name=> session->{name}||'AC',
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

# no security! 
get '/login/:name' => sub {
 session Name => params->{name};
 session Location => 'Pittsburgh';
 redirect('/explore');
};

get '/logout' => sub {
  session->destroy;
  redirect('/explore');
};

true;
