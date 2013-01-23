# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl EventEmitter.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { plan tests => 9 };
use EventEmitter;
ok(1); # If we made it this far, we're ok.

{
my $emitter = new EventEmitter();

$emitter->on('test', sub { is($_[0], 'bar') });
my $var = 'foo';
$emitter->once('test', sub { $var = $_[0] });
$emitter->emit('test', 'bar');
is($var, 'bar');
$var = 'foo';
$emitter->emit('test', 'bar');
is($var, 'foo');
}

{
my $emitter = new EventEmitter();

my $var = 'foo';
my $cb = sub { $var = $_[0] };
$emitter->on('test2', $cb);
is(($emitter->listeners('test2'))[0], $cb);
$emitter->removeListener('test2', $cb);
$emitter->emit('test2', 'bar');
is($var, 'foo');
}

is(scalar(keys(%EventEmitter::ALWAYS)), 0, 'Always cleaned up');
is(scalar(keys(%EventEmitter::ONCE)), 0, 'Once cleaned up');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

