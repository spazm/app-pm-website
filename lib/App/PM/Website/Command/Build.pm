use strict;
use warnings;

package App::PM::Website::Command::Build;
use base 'App::PM::Website::Command';

#ABSTRACT: build the website on-disk from the configuration files.

sub options
{
    my ($class, $app) = @_;

    #TODO: make this a config
    return (
        [ 'build_dir=s' => 'build dir path', 
            { default => "./website" } ],
        [   'date=s' => 'which month to build', 
            { default => $class->today() } ],
    );
}

sub validate
{

}

sub execute
{

}
1;
