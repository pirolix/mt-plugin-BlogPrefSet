package MT::Plugin::OMV::BlogPrefsSet;
use strict;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.10';

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
        id => $MYNAME,
        key => $MYNAME,
		name => $MYNAME,
		version => $VERSION,
		author_name => 'Open MagicVox.net',
		author_link => 'http://www.magicvox.net/',
		doc_link => 'http://www.magicvox.net/archive/2010/11141509/',
		description => <<HTMLHEREDOC,
<__trans phrase="Store and Switch the blog preferences.">
HTMLHEREDOC
        l10n_class => $MYNAME. '::L10N',
        schema_version => 0.0002,
        registry => {
            object_types => {
                blog => {
                    setting_id => {
                        label => 'Applied Prefs ID',
                        type => 'integer',
                        not_null => 0,
                    },
                },
                blog_setting => 'MT::Blog::Prefs',
            },
            callbacks => {
                'MT::App::CMS::template_source.cfg_prefs' => "\$${MYNAME}::${MYNAME}::CMS::template_source_cfg_prefs",
                'MT::App::CMS::template_param.cfg_prefs' => "\$${MYNAME}::${MYNAME}::CMS::template_param_cfg_prefs",
                'cms_post_save.blog' => "\$${MYNAME}::${MYNAME}::CMS::cms_post_save",
                'cms_post_save.website' => "\$${MYNAME}::${MYNAME}::CMS::cms_post_save",

                'MT::App::CMS::template_source.header' => "\$${MYNAME}::${MYNAME}::CMS::template_source_header",
                'MT::App::CMS::template_source.scope_selector' => "\$${MYNAME}::${MYNAME}::CMS::template_source_header",
                'MT::App::CMS::template_param' => "\$${MYNAME}::${MYNAME}::CMS::template_param_header",
            },
            applications => {
                cms => {
                    methods => {
                        remove_blog_prefs => "\$${MYNAME}::${MYNAME}::CMS::remove_blog_prefs",
                    },
                },
            },
        },
});
MT->add_plugin ($plugin);

sub instance { $plugin }

1;