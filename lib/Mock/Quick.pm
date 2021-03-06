package Mock::Quick;
use strict;
use warnings;
use Exporter::Declare;
use Mock::Quick::Class;
use Mock::Quick::Object;
use Mock::Quick::Method;
use Mock::Quick::Util ();

our $VERSION = '1.000_2';

default_export qobj      => sub { Mock::Quick::Object->new( @_ )    };
default_export qclass    => sub { Mock::Quick::Class->new( @_ )     };
default_export qtakeover => sub { Mock::Quick::Class->takeover( @_ )};
default_export qclear    => sub { \$Mock::Quick::Util::CLEAR        };

default_export qmeth => sub(&){ Mock::Quick::Method->new( @_ )};

1;

__END__

=pod

=head1 NAME

Mock::Quick - Quickly mock objects and classes, even temporarily replace them,
side-effect free.

=head1 DESCRIPTION

Mock-Quick is here to solve the current problems with Mocking libraries.

There are a couple Mocking libraries available on CPAN. The primary problems
with these libraries include verbose syntax, and most importantly side-effects.
Some Mocking libraries expect you to mock a specific class, and will unload it
then redefine it. This is particularily a problem if you only want to override
a class on a lexical level.

Mock-Object provides a declarative mocking interface that results in a very
concise, but clear syntax. There are seperate facilities for mocking object
instances, and classes. You can quickly create an instance of an object with
custom attributes and methods. You can also quickly create an anonymous class,
optionally inhereting from another, with whatever methods you desire.

Mock-Object also provides a tool that provides an OO interface to overriding
methods in existing classes. This tool also allows for the restoration of the
original class methods. Best of all this is a localized tool, when your control
object falls out of scope the original class is restored.

=head1 SYNOPSIS

=head2 MOCKING OBJECTS

    use Mock::Quick;

    my $obj = obj(
        foo => 'bar',            # define attribute
        do_it => qmeth { ... },  # define method
        ...
    );

    is( $obj->foo, 'bar' );
    $obj->foo( 'baz' );
    is( $obj->foo, 'baz' );

    $obj->do_it();

    # define the new attribute automatically
    $obj->bar( 'xxx' );

    # define a new method on the fly
    $obj->baz( qmeth { ... });

    # remove an attribute or method
    $obj->baz( qclear() );

=head2 MOCKING CLASSES

    use Mock::Quick;

    my $control = qclass(
        # Insert a generic new() method (blessed hash)
        -with_new => 1,

        # Inheritance
        -subclass => 'Some::Class',
        # Can also do
        -subclass => [ 'Class::A', 'Class::B' ],

        # generic get/set attribute methods.
        -attributes => [ qw/a b c d/ ],

        # Method that simply returns a value.
        simple => 'value',

        # Custom method.
        method => sub { ... },
    );

    my $obj = $control->packahe->new;

    # Override a method
    $control->override( foo => sub { ... });

    # Restore it to the original
    $control->restore( 'foo' );

    # Remove the anonymous namespace we created.
    $control->undefine();

=head2 TAKING OVER EXISTING CLASSES

    use Mock::Quick;

    my $control = qtakeover( 'Some::Package' );

    # Override a method
    $control->override( foo => sub { ... });

    # Restore it to the original
    $control->restore( 'foo' );

    # Destroy the control object and completely restore the original class Some::Package.
    $control = undef;

=head1 EXPORTS

Mock-Quick uses L<Exporter::Declare>. This allows for exports to be prefixed or renamed.
See L<Exporter::Declare/RENAMING IMPORTED ITEMS> for more information.

=over 4

=item $obj = qobj( attribute => value, ... )

Create an object. Every possible attribute works fine as a get/set accessor.
You can define other methods using qmeth {...} and assigning that to an
attribute. You can clear a method using qclear() as an argument.

See L<Mock::Quick::Object> for more.

=item $control = qclass( -config => ..., name => $value || sub { ... }, ... )

Define an anonymous package with the desired methods and specifications.

See L<Mock::Quick::Class> for more.

=item $control = qtakeover( $package )

Take control over an existing class.

See L<Mock::Quick::Class> for more.

=item qclear()

Returns a special reference that when used as an argument, will cause
Mock::Quick::Object methods to be cleared.

=item qmeth { my $self = shift; ... }

Define a method for an L<Mock::Quick::Object> instance.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2011 Chad Granum

Mock-Quick is free software; Standard perl licence.

Mock-Quick is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the license for more details.
