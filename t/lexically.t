use strict;
use warnings;
use Test::More tests => 7;

use lib 't';

my @expected_warnings;
BEGIN {
    push @expected_warnings,
        'Devel::Hide hides R.pm',
        'Devel::Hide hides Q.pm';
    $SIG{__WARN__} = sub {
        ok($_[0] eq shift(@expected_warnings)."\n",
            "got expected warning: $_[0]");
    }
}
END { ok(!@expected_warnings, "got all expected warnings") }

# hide R globally
use Devel::Hide qw(R);
note("R hidden globally, and noisily");
 
eval { require R }; 
like($@, qr/^Can't locate R\.pm in \@INC/,
    "correctly moaned about hiding R (globally)");

{
    use Devel::Hide qw(-lexically -quiet Q.pm);
    note("Q hidden lexically, quietly");

    eval { require Q }; 
    like($@, qr/^Can't locate Q\.pm in \@INC/,
        "correctly moaned about loading Q");
}

{
    use Devel::Hide qw(-lexically Q);
    note("Q hidden in a different scope, noisily");

    eval { require Q }; 
    like($@, qr/^Can't locate Q\.pm in \@INC/,
        "correctly moaned about loading Q");
}

note("Now we're outside that lexical scope");

eval { require Q };
ok(!$@, "nothing moaned about loading Q");
