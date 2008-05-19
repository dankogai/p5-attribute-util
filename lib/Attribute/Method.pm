package Attribute::Method;

use warnings;
use strict;
use Attribute::Handlers;
use B::Deparse;

our $VERSION = sprintf "%d.%02d", q$Revision: 1.1 $ =~ /(\d+)/g;

my $dp        = B::Deparse->new();
my %sigil2ref = (
    '$' => \undef,
    '@' => [],
    '%' => {},
);

sub import {
    my ( $class, @vars ) = @_;
    my $pkg = caller();
    push @vars, '$self';
    for my $var (@vars) {
        my $sigil = substr( $var, 0, 1, '' );
        no strict 'refs';
        *{ $pkg . '::' . $var } = $sigil2ref{$sigil};
    }
}

sub UNIVERSAL::Method : ATTR(RAWDATA) {
    my ( $pkg, $sym, $ref, undef, $args ) = @_;
    my $src = $dp->coderef2text($ref);
    if ($args) {
        $src =~ s/\{/sub{\nmy \$self = shift; my ($args) = \@_;\n/;
    }
    else {
        $src =~ s/\{/sub{\nmy \$self = shift;\n/;
    }
    no warnings 'redefine';
    *$sym = eval qq{ package $pkg; $src };
}

"Rosebud"; # for MARCEL's sake, not 1 -- dankogai

__END__

=head1 NAME

Attribute::Method - No more 'my $self = shift;'

=head1 SYNOPSIS

  package Lazy;
  use strict;
  use warnings;
  use Attribute::Method qw( $val );
	                # pass all parameter names here
                        # to make strict.pm happy
  sub new : Method { 
      bless { @_ }, $self 
  }
  sub set_foo : Method( $val ){
      $self->{foo} = $val;
  }
  sub get_foo : Method {
      $self->{val};
  }
  #....

=head1 DESCRIPTION

This Attribute makes your subroutine a method -- $self is
automagically set and the parameter list is supported.

This trick is actually introduced in "Perl Hacks", hack #47.
But the code sample therein is a little  buggy so have a look at this
module instead.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Dan Kogai, E<lt>dankogai@dan.co.jpE<gt>

=head1 COPYRIGHT

Copyright 2008 Dan Kogai.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), L<Attribute::Handlers>

Perl Hacks, isbn:0596526741

=cut
