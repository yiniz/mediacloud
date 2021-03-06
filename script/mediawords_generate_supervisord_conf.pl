#!/usr/bin/env perl

#
# Generate supervisord.conf by applying data in mediawords.yml to supervisord.conf.tt2
#

use strict;
use warnings;

use Modern::Perl "2015";
use MediaWords::CommonLibs;

use Data::Dumper;

use MediaWords::Util::Config;
use MediaWords::Util::Paths;

use Template;

sub main
{
    my $mc_root_path = MediaWords::Util::Paths::mc_root_path;

    my $template_file = "$mc_root_path/supervisor/supervisord.conf.tt2";
    my $output_file   = "$mc_root_path/supervisor/supervisord.conf";

    # template toolkit converts unquoted true and false values to '1' and '0', which
    # confuses the template processing
    my $config     = MediaWords::Util::Config::get_config;
    my $new_config = python_deep_copy( $config );
    $new_config->{ supervisor }->{ programs } ||= {};
    my $boolean_fields = [ 'autostart', 'autorestart', 'killasgroup', 'stopasgroup' ];
    MediaWords::Util::Config::set_config( $new_config );

    for my $b ( @{ $boolean_fields } )
    {
        for my $program ( values( %{ $new_config->{ supervisor }->{ programs } } ) )
        {
            next unless ( defined( $program->{ $b } ) );
            if ( !$program->{ $b } || ( lc( $program->{ $b } ) eq 'false' ) )
            {
                $program->{ $b . '_b' } = 'false';
            }
            elsif ( $program->{ $b } )
            {
                $program->{ $b . '_b' } = 'true';
            }
            else
            {
                $program->{ $b . '_b' } = $program->{ $b };
            }
        }
    }

    my $template = Template->new( ABSOLUTE => 1 );
    $template->process( $template_file, $new_config, $output_file )
      || die( "Unable to process template: " . $template->error() );
}

main();
