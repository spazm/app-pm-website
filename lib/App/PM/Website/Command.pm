package App::PM::Website::Command;
#use App::Cmd::Setup -command;
use strict;
use warnings;
use base 'App::Cmd::Command';
use Config::YAML;
use POSIX qw(strftime);
use Date::Parse qw(str2time);


#ABSTRACT: Parent class for App::PM::Website commands

sub opt_spec
{
    my ( $class, $app ) = @_;
    return (
        $class->options($app),
        [ 'config-file=s' => "path to configuration file" , 
            { required => 1, default => "config/pm-website.yaml"}],
        [],
        [ 'help|h!'    => "show this help" ],
        [ 'dry-run|n!' => "take no action" ],
        [ 'verbose|v+' => "increase verbosity" ],
    );
}

sub validate_args
{
    my ( $self, $opt, $args ) = @_;
    die $self->_usage_text if $opt->{help};
    $self->{config} = Config::YAML->new( config => $opt->{config_file} )
        or die $self->usage_error("failed to open configuration file: $!");
    $self->validate( $opt, $args );
}

sub meetings
{
    my $self = shift;
    my $meetings = $self->{config}->get_meetings;
    for my $meeting (@$meetings)
    {
        $meeting->{epoch} ||= str2time( $meeting->{event_date}, 'PST' );
    }
    sort { $b->{epoch} <=> $a->{epoch} } @$meetings;
}

sub today
{
    my ($class) = @_;
    return unless $class;
    $class->date_as_ymd();
}

sub yesterday
{
    my ($class) = @_;
    return unless $class;
    $class->date_as_ymd( time - 24 * 60 * 60 );
}

sub date_as_ymd
{
    my ( $class, $time ) = @_;
    $time ||= time();
    return strftime( "%Y-%m-%d", localtime($time) );
}

1;
