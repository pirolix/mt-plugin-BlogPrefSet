package BlogPrefsSet::L10N::ja;

#BEGIN{ require utf8 if $MT::VERSION >= 5.0; }

use strict;
use base 'BlogPrefsSet::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
    'Store and Switch the blog preferences.' => 'ブログ設定を保存し、切り替えることができるようにします。',
    # cfg_prefs
    'Preferences Set Name' => '設定セットの名前',
    'Name this settings. Changing the name will create the new settings set.' => 'この設定に名前をつけてください。名前を変更すると、新しいセットが作られます。',
    'Remove this preferences set' => 'この設定セットを削除する',
    'Are you sure you want to remove this preferences set ?' => 'この設定セットを削除してもよろしいですか？',
    'General Settings are going to be switched. Make sure of preferences and save changes to apply.' => '全般設定が切り替えられようとしています。この設定でよければ変更を保存してください。',
);

1;