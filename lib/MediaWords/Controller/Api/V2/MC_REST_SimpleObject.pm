package MediaWords::Controller::Api::V2::MC_REST_SimpleObject;
use Modern::Perl "2013";
use MediaWords::CommonLibs;

use MediaWords::DBI::StorySubsets;
use MediaWords::Controller::Api::V2::MC_Action_REST;
use strict;
use warnings;
use base 'Catalyst::Controller';
use JSON;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use Moose;
use namespace::autoclean;
use List::Compare;
use Carp;

=head1 NAME

MediaWords::Controller::Media - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

BEGIN { extends 'MediaWords::Controller::Api::V2::MC_Controller_REST' }

use constant ROWS_PER_PAGE => 20;

use MediaWords::Tagger;

# ## TODO move these to a centralized location instead of copying them in every API class 
# #A list top level object fields to include by default in API results unless all_fields is true
# Readonly my $default_output_fields => [ qw ( name url media_id ) ];
# sub _purge_extra_fields:
# {
#     my ( $self, $obj ) = @_;

#     my $new_obj = {};

#     foreach my $default_output_field ( @ {$default_output_fields } )
#     {
# 	$new_obj->{ $default_output_field } = $obj->{ $default_output_field };
#     }

#     return $new_obj;
# }

# sub _purge_extra_fields_obj_list
# {
#     my ( $self, $list ) = @_;

#     return [ map { $self->_purge_extra_fields( $_ ) } @{ $list } ];
# }

sub get_table_name
{
    die "Method not implemented";
}

sub single : Local : ActionClass('+MediaWords::Controller::Api::V2::MC_Action_REST')
{
}

sub single_GET : Local
{
    my ( $self, $c, $id ) = @_;

    my $table_name = $self->get_table_name();

    my $id_field = $table_name . "_id";

    my $query = "select * from $table_name where $id_field = ? ";

    my $items = $c->dbis->query( $query, $id )->hashes();

    $self->status_ok( $c, entity => $items );
}

sub list_query_filter_field
{
    return;
}

sub list_api_requires_filter_field
{
    my ( $self ) = @_;

    return defined($self->list_query_filter_field() ) && $self->list_query_filter_field();
}

sub list : Local : ActionClass('+MediaWords::Controller::Api::V2::MC_Action_REST')
{
}

sub list_GET : Local
{
    my ( $self, $c ) = @_;

    say STDERR "starting list_GET";

    my $table_name = $self->get_table_name();

    my $id_field = $table_name . "_id";

    my $last_id_param_name = 'last_' . $id_field;

    my $last_id = $c->req->param( $last_id_param_name );
    $last_id //= 0;

    say STDERR "last_id: $last_id";

    my $all_fields = $c->req->param( 'all_fields' );
    $all_fields   //= 0;

    my $rows =  $c->req->param( 'rows' );
    say STDERR "rows $rows";

    $rows //= ROWS_PER_PAGE;

    my $list;

    if ( $self->list_api_requires_filter_field() )
    {
	my $query_filter_field_name = $self->list_query_filter_field();

	my $filter_field_value = $c->req->param( $query_filter_field_name );

	if (!defined( $filter_field_value ) )
	{
	    $self->status_bad_request(
		$c,
		message => "Missing required param $query_filter_field_name",
		);

	    return;
	}

	my $query = "select * from $table_name where $id_field > ? and $query_filter_field_name = ? ORDER by $id_field asc limit ? ";

	$list = $c->dbis->query( $query , $last_id, $filter_field_value, $rows )->hashes;
    }
    else
    {
	my $query = "select * from $table_name where $id_field > ? ORDER by $id_field asc limit ? ";

	$list = $c->dbis->query( $query , $last_id, $rows )->hashes;
    }

    # if ( ! $all_fields )
    # {
    # 	say STDERR "Purging extra fields in";
    # 	say STDERR Dumper( $media );
    # 	$media = $self->_purge_extra_fields_obj_list( $media );
    # 	say STDERR "Purging result:";
    # 	say STDERR Dumper( $media );
    # }

    # $self->_add_data_to_media( $c->dbis, $media );

    $self->status_ok( $c, entity => $list );
}

=head1 AUTHOR

David Larochelle

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
