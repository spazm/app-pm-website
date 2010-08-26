use strict;
use warnings;

package App::PM::Website::Command::Build;
use base 'App::PM::Website::Command';

use Template;
use Data::Dumper;

sub abstract { "build the website on-disk from the configuration files." }

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
    my( $self, $opt, $args ) = @_;
    
    my $meeting = $self->{config}->get_meetings->[-1];
    my $tt_vars = {
        m => $meeting,
        meetings => [ reverse @{ $self->{config}->get_meetings }],
        presenter => $self->{config}->get_presenter,
        location => $self->{config}->get_location,
    };
    my $execute_options = {
        template_file => "templates/index.tt",
        tt_vars => $tt_vars,
        output_file => "$opt->{build_dir}/index.html",
    };
    $self->execute_template( $opt, $execute_options );

}

sub execute_template
{
    my ($self, $opt, $tt_options) = @_;

    my $template_options = {
        INCLUDE_PATH => './',
        INTERPOLATE  => 1,
    };
    my $tt = Template->new( {} )
        || die "$Template::ERROR\n";

    my @opts = (
        @$tt_options{
            qw(
                template_file tt_vars output_file )
            },
        ( binmode => ':utf8' )
    );

    use Data::Dumper;
    print Dumper { tt_process => \@opts }
        if $opt->{verbose};

    my $success = 1;
    unless ($opt->{dry_run} )
    {
        $success = $tt->process( @opts )
            or die $tt->error(), "\n";
    }

    return $success;
}
1;
