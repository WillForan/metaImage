package vone;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use Data::Dumper;

our $VERSION = '0.1';

#hook 'before' => sub {
# #request->path_info()
#};

get '/index' => sub {
    template 'index';
};

get '/' => sub {
    redirect('/explore');
};

get '/image/:hash' => sub {
    my $hash = param('hash');
    my @pics   = mongo->get_database('stv1')->get_collection('Pics')->find({Hash => "$hash"})->all();

    # if name is owner
    template 'edit', {pics=>\@pics};
    # othwerwise go to image view
    #template 'edit', {pics=>\@pics};
};
post '/image/:hash' => sub {
    my $hash = param('hash');
    my $Pics=mongo->get_database('stv1')->get_collection('Pics');
    # this shouldn't be an array
    my @pics   = $Pics->find({Hash => "$hash"})->all();
    # update pic

    for my $p (qw/Latitude Longitude Tags Event/) {
        my $value = params->{$p};
	if($p eq "Tags") { 
	    my @tags = split(',',$value); # if($p=~/Tags/);
	    $Pics->find_and_modify({query=>{Hash => $hash},update=>{'$set'=>{Tags=>\@tags}    }});
	}else {
	    $Pics->find_and_modify({query=>{Hash => $hash},update=>{'$set'=>{$p=>$value}}});
	}
	
    }

    @pics   = $Pics->find({Hash => "$hash"})->all();

    # if name is owner
    template 'edit', {pics=>\@pics};
    # othwerwise go to image view
    #template 'edit', {pics=>\@pics};
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
