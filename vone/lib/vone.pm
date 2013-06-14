package vone;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;

our $VERSION = '0.1';

hook 'before' => sub {
 #request->path_info()
 redirect('/login') if request->path_info =~ m/upload/ && !params->{name} ;
};

get '/' => sub {
    template 'index';
};

get '/explore' => sub {
    my @pictures = mongo->get_database('stv1')->get_collection('Peps')->find()->all();
    #debug(\@pictures);
    template 'explore', { location => 'Pittsburgh', name=> session->{name}||'AC', pics => \@pictures };
};

# no security! 
get '/login/:name' => sub {
 session name => params->{name};
 redirect('/explore');
};

get '/logout' => sub {
  session->destroy;
  redirect('/explore');
};

true;
