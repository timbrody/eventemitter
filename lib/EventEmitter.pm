package EventEmitter;

use 5.006000;
use strict;
use warnings;

our @ISA = qw();

our $VERSION = '0.01';

our %ALWAYS;
our %ONCE;

=head1 NAME

EventEmitter - call callbacks in response to events

=head1 SYNOPSIS

  use EventEmitter;
  
  $emitter = new EventEmitter();
  $emitter->on('election', sub {
	  print "$_[0] won!\n";
	  print "$_[1] lost!\n";
  });
  $emitter->emit('election', 'Obama', 'Romney');

=head1 DESCRIPTION

Perl translation of the Node.js EventEmitter implementation.

Register callbacks and emit events that trigger those callbacks.

Events are identified by anything that can be stringified.

=head1 METHODS

=over 4

=cut

=item $emitter = EventEmitter->new;

Returns a new EventEmitter object, which is a blessed anonymous scalar.

Sub-classes will probably want to do something different.

=cut

# Preloaded methods go here.

sub new
{
	my( $class ) = @_;

	my $self;

	return bless \$self, $class;
}

sub DESTROY
{
	delete $ALWAYS{$_[0]};
	delete $ONCE{$_[0]};
}

=item $emitter = $emitter->addListener(EVENTID, CALLBACK)

Adds a listener to the end of the listeners array for the specified event.

CALLBACK must be a CODEREF. If you need to call a subroutine on an object use a closure:

	$emitter->on('close', sub {
		$obj->parent_closed();
	});

=cut

sub addListener
{
	my( $self, $eventid, $cb ) = @_;

	push @{$ALWAYS{$self}{$eventid}}, $cb;

	$self->emit('newListener', $eventid, $cb);

	$self;
}

=item $emitter = $emitter->on(EVENTID, CALLBACK)

Synonym for L</addListener>.

=cut

sub on { &addListener }

=item $emitter = $emitter->once(EVENTID, CALLBACK)

Adds a one time listener for the event. This listener is invoked only the next time the event is fired, after which it is removed.

=cut

sub once
{
	my( $self, $eventid, $cb ) = @_;

	push @{$ONCE{$self}{$eventid}}, $cb;

	$self->emit('newListener', $eventid, $cb);

	$self;
}

=item $emitter->emit(EVENTID [, ARG1 [, ARG2 ... ] ])

Execute each of the listeners in order with the supplied arguments.

=cut

sub emit
{
	my( $self, $eventid, @args ) = @_;

	local $_;
	&$_(@args) for @{$ALWAYS{$self}{$eventid} || []};
	&$_(@args) for @{delete($ONCE{$self}{$eventid}) || []};
}

=item $emitter->removeListener(EVENTID, CALLBACK)

Remove a listener from the listener array for the specified event.

=cut

sub removeListener
{
	my ($self, $eventid, $cb) = @_;

	local $_;
	for($ALWAYS{$self}{$eventid}, $ONCE{$self}{$eventid})
	{
		next if !defined $_;
		@$_ = grep { $_ ne $cb } @$_;
	}
}

=item $emitter->removeAllListeners([EVENTID])

Removes all listeners, or those of the specified event.

=cut

sub removeAllListeners
{
	my ($self, $eventid) = @_;

	if (defined $eventid) {
		delete $ALWAYS{$self}{$eventid};
		delete $ONCE{$self}{$eventid};
	}
	else {
		delete $ALWAYS{$self};
		delete $ONCE{$self};
	}
}

=item $arr = $emitter->listeners(EVENTID)

Returns an array of listeners for the specified event.

=cut

sub listeners
{
	my ($self, $eventid) = @_;

	return(
		@{$ALWAYS{$self}{$eventid} || []},
		@{$ONCE{$self}{$eventid} || []},
	);
}

1;
__END__

=back

=head1 Events

=over 4

=item newListener

=over 8

=item EVENTID String The event name

=item CALLBACK Subroutine The event handler callback

=back

This event is emitted any time someone adds a new listener.

=back

=head1 SEE ALSO

http://nodejs.org/api/events.html

=head1 AUTHOR

Tim Brody, E<lt>tdb2@ecs.soton.ac.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Tim Brody

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

API documentation is Copyright (C) Joyent, Inc. and other Node contributors.

See Node.JS LICENSE.

=cut
