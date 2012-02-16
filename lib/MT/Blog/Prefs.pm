package MT::Blog::Prefs;

use strict;
use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'blog_id' => 'integer',
        'name' => 'string(255)',
        'data' => 'blob',
    },
    indexes => {
        blog_id => 1,
    },
    datasource => 'blog_prefs',
    primary_key => 'id',
    child_of => 'MT::Blog',
});

sub class_label {
    'Blog Preference';
}
*class_label_plural = \&class_label;

1;