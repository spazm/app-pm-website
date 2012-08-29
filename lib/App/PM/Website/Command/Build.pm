use strict;
use warnings;

package App::PM::Website::Command::Build;
use base 'App::PM::Website::Command';

use Template;
use Data::Dumper;

#ABSTRACT: render the website to local disk from the configuration files.

sub options
{
    my ($class, $app) = @_;

    return (
        [ 'template_dir=s' => 'template dir path',
            { default => "template" } ],
        [ 'build_dir=s' => 'build dir path',
            { default => "./website" } ],
        [ 'date=s' => 'which month to build',
            { default => scalar $class->today() } ],
    );
}

sub validate
{
    my ($self, $opt, $args ) = @_;
    $self->validate_or_create_dir($opt,'build_dir');
    $self->validate_required_dir($opt, 'template_dir');

    die $self->usage_error( "no arguments allowed") if @$args;

    return 1;
}

sub execute
{
    my( $self, $opt, $args ) = @_;

    my ($meeting, @past_meetings) = $self->meetings();
    my $loc = $meeting->{location} ||
        $self->{config}{config}{location}{default};
    my $tt_vars = {
        m         => $meeting,
        meetings  => \@past_meetings,
        presenter => $self->{config}->get_presenter,
        locations => $self->{config}->get_location,
        l         => $self->{config}->get_location->{$loc},
    };
    my $execute_options = {
        template_file => "$opt->{template_dir}/index.tt",
        output_file   => "$opt->{build_dir}/index.html",
        tt_vars       => $tt_vars,
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
        @$tt_options{ qw( template_file tt_vars output_file ) },
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
