# --
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars (qw($Self));

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase  => 1,
        UseTmpArticleDir => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

my $ItemID = $FAQObject->FAQAdd(
    Title       => 'Some Text',
    CategoryID  => 1,
    StateID     => 1,
    LanguageID  => 1,
    Keywords    => 'some keywords',
    Field1      => 'Problem...',
    Field2      => 'Solution...',
    ContentType => 'text/html',
    UserID      => 1,
);
$Self->True(
    $ItemID,
    'FAQAdd()',
);

my %ExpectedDataRaw = $FAQObject->FAQGet(
    ItemID     => $ItemID,
    ItemFields => 1,
    UserID     => 1,
);

my @Tests = (
    {
        Name    => 'No Params',
        Config  => {},
        Success => 0,
    },
    {
        Name   => 'Success',
        Config => {
            Data => {
                ItemID => $ItemID,
            },
        },
        Success => 1,
    },

);

my $BackedObject = $Kernel::OM->Get('Kernel::GenericInterface::Event::ObjectType::FAQ');

TEST:
for my $Test (@Tests) {

    my %ObjectData = $BackedObject->DataGet( %{ $Test->{Config} } );

    my %ExpectedData;
    if ( $Test->{Success} ) {
        %ExpectedData = %ExpectedDataRaw;
    }

    $Self->IsDeeply(
        \%ObjectData,
        \%ExpectedData,
        "$Test->{Name} DataGet()"
    );
}

# Cleanup is done by RestoreDatabase.
1;