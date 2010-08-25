package Unit::Test::App::PM::Website;
use base Test::Class;
use Test::More;
use App::Cmd::Tester;

sub load_module : Tests()
{
    use_ok( 'App::PM::Website' );
}

1;
