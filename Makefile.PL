BEGIN { require 5.008 }
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

use Config;
my %META = (
  name => 'Devel-GlobalPhase',
  license => 'perl_5',
  resources => {
    repository => {
      type => 'git',
      url => 'git://github.com/haarg/Devel-GlobalPhase.git',
      web => 'http://github.com/haarg/Devel-GlobalPhase',
    },
    bugtracker => {
      web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Devel-GlobalPhase',
      mailto => 'bug-Devel-GlobalPhase@rt.cpan.org',
    },
    license => [ 'http://dev.perl.org/licenses/' ],
  },
  prereqs => {
    runtime => {
      requires => {
        perl => 5.008,
      },
    },
  },
  no_index => {
    directory => [ 't', 'xt' ]
  },
);

my %MM_ARGS = (
  PREREQ_PM       => {
    $Config{useithreads} ? (threads => 1.07) : (),
  },
);

##############################################################################
require ExtUtils::MakeMaker;
(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

# have to do this since old EUMM dev releases miss the eval $VERSION line
my $eumm_version  = eval $ExtUtils::MakeMaker::VERSION;
my $mymeta        = $eumm_version >= 6.57_02;
my $mymeta_broken = $mymeta && $eumm_version < 6.57_07;

($MM_ARGS{NAME} = $META{name}) =~ s/-/::/g;
($MM_ARGS{VERSION_FROM} = "lib/$MM_ARGS{NAME}.pm") =~ s{::}{/}g;
$MM_ARGS{LICENSE} = $META{license}
  if $eumm_version >= 6.30;
$MM_ARGS{NO_MYMETA} = 1
  if $mymeta_broken;
$MM_ARGS{META_ADD} = { 'meta-spec' => { version => 2 }, %META }
  unless -f 'META.yml';

for (qw(configure build test runtime)) {
  my $key = $_ eq 'runtime' ? 'PREREQ_PM' : uc $_.'_REQUIRES';
  my $r = $MM_ARGS{$key} = {
    %{$META{prereqs}{$_}{requires} || {}},
    %{delete $MM_ARGS{$key} || {}},
  };
  defined $r->{$_} or delete $r->{$_} for keys %$r;
}

$MM_ARGS{MIN_PERL_VERSION} = delete $MM_ARGS{PREREQ_PM}{perl} || 0;

delete $MM_ARGS{MIN_PERL_VERSION}
  if $eumm_version < 6.47_01;
$MM_ARGS{BUILD_REQUIRES} = {%{$MM_ARGS{BUILD_REQUIRES}}, %{delete $MM_ARGS{TEST_REQUIRES}}}
  if $eumm_version < 6.63_03;
$MM_ARGS{PREREQ_PM} = {%{$MM_ARGS{PREREQ_PM}}, %{delete $MM_ARGS{BUILD_REQUIRES}}}
  if $eumm_version < 6.55_01;
delete $MM_ARGS{CONFIGURE_REQUIRES}
  if $eumm_version < 6.51_03;

ExtUtils::MakeMaker::WriteMakefile(%MM_ARGS);
