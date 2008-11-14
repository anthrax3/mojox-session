use Test::More tests => 7;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');
use_ok('MojoX::Session::Transport::Cookie');

use DBI;
use Mojo::Transaction;
use Mojo::Cookie::Response;

my $dbh = DBI->connect("dbi:SQLite:table.db") or die $DBI::errstr;

my $cookie = Mojo::Cookie::Request->new(name => 'sid', value => 'bar');

my $tx = Mojo::Transaction->new();
$tx->req->cookies($cookie);

my $session = MojoX::Session->new(
    store     => MojoX::Session::Store::DBI->new(dbh  => $dbh),
    transport => MojoX::Session::Transport::Cookie->new(tx => $tx)
);

ok(not defined $session->load());

$session->create();
$session->flush();
my $sid = $session->sid;
ok($sid);

$cookie = Mojo::Cookie::Request->new(name => 'sid', value => $sid);

$tx->req->cookies($cookie);
ok($session->load());
is($session->sid, $sid);