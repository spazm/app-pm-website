use strict;
use warnings;

package App::PM::Website::Command::Install;
use base 'App::PM::Website::Command';
use Net::Netrc;
use HTTP::DAV;
use Data::Dumper;

#ABSTRACT: install the built website into production via caldav

sub options
{
    my ($class, $app) = @_;
    return (
        [ 'url=s'         => 'path to webdav directory' ],
        [ 'filename=s'    => 'upload name, rather than index.html' , {default => 'index.html' }],
        [ 'username=s'    => 'username for webdav, override .netrc' ],
        [ 'password=s'    => 'password for webdav, override .netrc' ],
        [ 'certificate=s' => 'path to ca certificate' ],
    );
}

sub validate
{
    my ($self, $opt, $args ) = @_;

    $self->validate_url($opt);
    $self->validate_login( $opt );

    if(@$args)
    {
        die $self->usage_error("no arguments allowed") 
    }
}
sub validate_url
{
    my ($self, $opt ) = @_;
    my $c = $self->{config}->{config};

    $opt->{url} ||= $c->{url};
    die $self->usage_error( "url must be defined on command line or in config file") 
        unless $opt->{url};
}
sub validate_login
{
    my ( $self, $opt ) = @_;

    my $c       = $self->{config}->{config};
    my $url     = $opt->{url};
    my $machine = $opt->{machine} || $c->{machine};

    $opt->{username} ||= $c->{username};
    $opt->{password} ||= $c->{password};

    return 1 if ( $opt->{username} && $opt->{password} );

    if( $machine  )
    {
        my $mach = Net::Netrc->lookup($machine);
        if ( defined $mach ) 
        {
            $opt->{username} ||= $mach->login();
            $opt->{password} ||= $mach->password();
        }
    }

    return 1 if ( $opt->{username} && $opt->{password} );

    die $self->usage_error(
        "username and password must be defined on the command line, config file or in .netrc"
    );
}

sub execute
{
    my ( $self, $opt, $args ) = @_;

    my $webdav             = HTTP::DAV->new();
    if( $opt->{certificate} )
    {
        print Dumper { certificate => $opt->{certificate} };
        $webdav->get_user_agent->ssl_opts(SSL_ca_file => $opt->{certificate}) 
    }
    my %webdav_credentials = (
        -user  => $opt->{username},
        -pass  => $opt->{password},
        -url   => $opt->{url},
        -realm => "groups.perl.org",
    );
    print Dumper { credentials => \%webdav_credentials };
    $webdav->credentials(%webdav_credentials);
    $webdav->open( -url => $opt->{url} )
        or die sprintf( "failed to open url [%s] : %s\n",
        $opt->{url}, $webdav->message() );

    my %put_options = (
        -local => "website/$opt->{filename}",
        -url   => $opt->{url},
    );
    print Dumper { put_options => \%put_options };
    my $success = $opt->{dry_run} ? 1 : $webdav->put(%put_options);

    die sprintf( "failed to put file website/%s to url %s : %s\n",
        $opt->{filename}, $opt->{url}, $webdav->message(), )
        unless $success;

    return $success;
}
1;
