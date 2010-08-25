use strict;
use warnings;

package App::PM::Website::Command::Install;
use base 'App::PM::Website::Command';

#ABSTRACT: install the built website into production via caldav

sub options
{
    my ($class, $app) = @_;
    return (
        [ 'url=s'      => 'path to webdav directory' ],
        [ 'filename=s' => 'upload name, rather than index.html' ],
    );
}

sub validate
{

}

sub execute
{

}
1;
