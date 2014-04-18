use strict;
use warnings;

package Net::FreshBooks::API::Role::Iterator;

use Moose::Role;
use Data::Dump qw( dump );

sub get {
    my $self   = shift;
    my $args   = shift || {};
    my $method = $self->method_string( 'get' );

    my $res = $self->send_request(
        {   _method => $method,
            %$args,
        }
    );

    return $self->_fill_in_from_node( $res );
}

sub get_all {

    my $self = shift;
    my $args = shift || {};

    # override any pagination
    $args->{per_page} = 100;

    my @all      = ();
    my $per_page = 100;
    my $page     = 1;

    while ( 1 ) {

        my @subset = ();
        $args->{page} = $page;
        my $iter = $self->list( $args );

        while ( my $obj = $iter->next ) {
            push @subset, $obj;
        }
        push @all, @subset;

        last if scalar @subset < $per_page;

        ++$page;
    }

    return \@all;

}

sub list {
    my $self = shift;
    my $args = shift || {};

    return Net::FreshBooks::API::Iterator->new(
        {   parent_object => $self,
            args          => $args,
        }
    );
}

1;

# ABSTRACT: Read-only roles

=pod

=head1 SYNOPSIS

These roles are used for iterating over returned results as well as handling
pagination. See the various modules which implement these methods for specific
examples of how these methods are used.

=head2 get( $args )

=head2 get_all( $args )

Iterates over all pages of results provided by FreshBooks. Calling get_all
means you don't need to worry about explicitly handling pagination in
requests. Returns an ARRAYREF of the requested objects.

=head2 list( $args )

Returns an iterator object.

=cut
