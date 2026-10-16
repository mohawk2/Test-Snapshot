use Test::More 0.96;
use Test::Snapshot;
use Test2::API qw(context intercept);
use File::Spec;
use File::Basename qw(dirname);

# snapshot path below snapshots/<testfile>/
sub rel_path {
  my $ctx = context();
  my $filename = Test::Snapshot::_get_filename($ctx, 'desc');
  $ctx->release;
  my $dir = File::Spec->catdir(dirname(File::Spec->rel2abs($0)), 'snapshots');
  my (undef, @parts) = File::Spec->splitdir(File::Spec->abs2rel($filename, $dir));
  join '/', @parts;
}

sub path_is {
  my ($expected) = @_;
  my $ctx = context();
  is rel_path(), $expected, "path in $expected";
  $ctx->release;
}

for my $top (qw(t1 t2)) {
  subtest $top => sub {
    path_is("$top/desc");
    for my $name (qw(a b)) {
      subtest $name => sub {
        path_is("$top/$name/desc");
        subtest inner => sub { path_is("$top/$name/inner/desc") };
      };
    }
    path_is("$top/desc");
  };
}
path_is('desc');

subtest intercept => sub {
  subtest sibling => sub { pass };
  my $got;
  intercept { $got = rel_path() };
  is $got, 'intercept/desc', 'intercept hub adds no name';
};

subtest child => sub {
  subtest sibling => sub { pass };
  my $child = Test::Builder->new->child('kid');
  path_is('child/kid/desc');
  $child->finalize;
};

done_testing;
