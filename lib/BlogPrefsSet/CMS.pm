package BlogPrefsSet::CMS;
use strict;
use MT::Blog;
use MT::Blog::Prefs;
use MT::Serialize;

sub MYNAME { (split /::/, __PACKAGE__)[0]; }

sub instance { MT->component (&MYNAME); }



### Callbacks - template_*.cfg_prefs
sub template_source_cfg_prefs {
    my ($cb, $app, $tmpl) = @_;

    my $new = &instance->translate_templatized (<<HTMLHEREDOC);
    <mtapp:setting
        id="set_name"
        required="1"
        label="<__trans phrase="Preferences Set Name">"
        content_class="field-content-input"
        hint="<__trans phrase="Name this settings. Changing the name will create the new settings set.">"
        show_hint="1">
        <input type="hidden" name="set_id" value="<mt:var set_id>" />
        <input type="text" name="set_name" id="set_name" class="full-width" value="<mt:var name="set_name" escape="html">" size="255" />
<mt:if name="blog_settings">
        <a href="<mt:var mt_url>?__mode=remove_blog_prefs&amp;blog_id=<mt:var blog_id>&amp;blog_settings=<mt:var set_id>" onclick="return confirm('<__trans phrase="Are you sure you want to remove this preferences set ?">');">
          <img src="<mt:var static_uri>images/status_icons/close.gif" alt="<__trans phrase="Remove this preferences set">" title="<__trans phrase="Remove this preferences set">"/></a>
</mt:if>
    </mtapp:setting>
HTMLHEREDOC

    if (5.1 <= $MT::VERSION) {
        my $old = quotemeta (<<'HTMLHEREDOC');
    <h2><__trans phrase="[_1] Settings" params="<mt:var name="object_label" capitalize="1">"></h2>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$new$1/;
    }
    elsif (5.0 <= $MT::VERSION) {
        my $old = quotemeta (<<'HTMLHEREDOC');
    <h3><__trans phrase="[_1] Settings" params="<mt:var name="object_label" capitalize="1">"></h3>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$new$1/;
    }
}

sub template_param_cfg_prefs {
    my ($cb, $app, $param) = @_;

    my $blog_id = $param->{blog_id};
    my $blog = MT::Blog->load ({ id => $blog_id })
        or return; # never reach here

    $param->{set_id} = 0;
    $param->{set_name} = 'Default';
    my $setting_id = $blog->setting_id;
    if (defined $app->param ('blog_settings')) {
        $setting_id = $app->param ('blog_settings');
        $param->{error} = &instance->translate ('General Settings are going to be switched. Make sure of preferences and save changes to apply.');
    }
    if (defined (my $setting = MT::Blog::Prefs->load ({ id => $setting_id }))) {
        $param->{set_id} = $setting->id;
        $param->{set_name} = $setting->name;

        # Restore the settings from frozen data
        my $thawed = MT::Serialize->new('MT')->unserialize ($setting->data);
        map { $param->{$_} = $$thawed->{$_}; } keys %$$thawed;
    }
}

### Callbacks - cms_post_save.*
sub cms_post_save {
    my ($cb, $app, $obj) = @_;

    my $blog_id = $app->param ('blog_id')
        or return 1;
    my $blog = MT::Blog->load ({ id => $blog_id })
        or return 1;

    my $set_name = defined $app->param ('set_name')
        ? $app->param ('set_name') ne ''
            ? $app->param ('set_name')
            : 'Default'
        : 'Default';

    my $data;
    map { $data->{$_} = $app->param($_) if defined $app->param($_); } @{MT::Blog->column_names};
    $data = MT::Serialize->new('MT')->serialize (\$data);

    my ($set_id, $setting);
    if (defined ($set_id = $app->param ('set_id')) && $set_id) {
        if (defined ($setting = MT::Blog::Prefs->load ({ blog_id => $blog_id, id => $set_id }))) {
            # Changing the name will create the new settings set.
            $setting = undef if $setting->name ne $set_name;
        }
    }
    $setting = MT::Blog::Prefs->new unless $setting; # new setting set
    $setting->blog_id ($blog_id);
    $setting->name ($set_name);
    $setting->data ($data);
    $setting->save;

    $blog->setting_id ($setting->id); # setting->id must be a valid id
    $blog->update;

    1;
}



### Callbacks - template_*.header for MT50
sub template_source_header {
    my ($cb, $app, $tmpl) = @_;

    my $new = &instance->translate_templatized (<<HTMLHEREDOC);
<mt:if name="blog_settings">
  <select id="blog-settings" onchange="onChangeBlogSettings(this);"><mt:loop name="blog_settings">
    <option value="<mt:var name="value">"<mt:if name="selected"> selected="selected"</mt:if>><mt:var name="name" escape="html"></option>
  </mt:loop></select>
</mt:if>
HTMLHEREDOC

    if (5.1 <= $MT::VERSION) {
        ### Blogs
        my $old = <<'HTMLHEREDOC'; chomp $old; $old = quotemeta $old;
<a href="<$mt:var name="mt_url"$>?__mode=dashboard&amp;blog_id=<$mt:var name="curr_blog_id"$>"><mt:var name="curr_blog_name" escape="html"></a>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$1$new/g;

        ### Website
        $new = qq(<mt:if name="scope_type" eq="website">$new</mt:if>);
        $old = <<'HTMLHEREDOC'; chomp $old; $old = quotemeta $old;
<a href="<$mt:var name="mt_url"$>?__mode=dashboard&amp;blog_id=<$mt:var name="curr_website_id"$>"><mt:var name="curr_website_name" escape="html"></a>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$1$new/g;
    }

    elsif (5.0 <= $MT::VERSION) {
    ### Blogs
        my $old = <<'HTMLHEREDOC'; chomp $old; $old = quotemeta $old;
<em><a href="<$mt:var name="mt_url"$>?__mode=dashboard&amp;blog_id=<$mt:var name="curr_blog_id"$>"><mt:var name="curr_blog_name" escape="html"></a></em>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$1$new/g;

    ### Website
        $new = qq(<mt:if name="scope_type" eq="website">$new</mt:if>);
        $old = <<'HTMLHEREDOC'; chomp $old; $old = quotemeta $old;
<em><a href="<$mt:var name="mt_url"$>?__mode=dashboard&amp;blog_id=<$mt:var name="curr_website_id"$>"><mt:var name="curr_website_name" escape="html"></a>
HTMLHEREDOC
        $$tmpl =~ s/($old)/$1$new/g;
    }


    ### Style
    $$tmpl = <<'HTMLHEREDOC'. $$tmpl;
<mt:setvarblock name="html_head" append="1">
<style type="text/css">
#blog-settings {
    vertical-align: top;
    margin-top: 5px;
    margin-left: 10px;
}

.website #selector-nav-list #current-website,
#selector-nav-list .current em
{ max-width: none; }
</style>

<script type="text/javascript">
function onChangeBlogSettings (slct, id) {
    if (slct && slct.options && (id = slct.options[slct.selectedIndex].value))
        window.location.href = '<$mt:var name="mt_url"$>?__mode=cfg_prefs&blog_id=<$mt:var name="blog_id"$>&blog_settings=' + id;
}
</script>
</mt:setvarblock>
HTMLHEREDOC
}

sub template_param_header {
    my ($cb, $app, $param) = @_;

    $app->can_do('access_to_blog_config_screen')
        or return; # do nothing

    my $blog_id = $param->{blog_id}
        or return; # do nothing
    my $blog = MT::Blog->load ({ id => $blog_id })
        or return; # do nothing

    my @blog_settings;
    my $iter = MT::Blog::Prefs->load_iter ({ blog_id => $blog_id });
    while (my $settings = $iter->()) {
        push @blog_settings, {
            value => $settings->id,
            name => $settings->name,
            selected => defined $blog->setting_id && ($blog->setting_id == $settings->id),
        };
    }
    $param->{'blog_settings'} = \@blog_settings if 1 < @blog_settings;
}



### Methods - remove_blog_settings
sub remove_blog_prefs {
    my ($app) = @_;

    $app->can_do('access_to_blog_config_screen')
        or return $app->error( $app->translate('Permission denied.') );

    my $blog_id = $app->param ('blog_id')
        or return $app->error ($app->translate ('Invalid blog_id'));

    if (defined (my $blog_settings = $app->param ('blog_settings'))) {
        if (defined (my $setting = MT::Blog::Prefs->load ({ id => $blog_settings }))) {
            $setting->remove;
        }
    }

    $app->redirect ($app->uri (
        mode => 'cfg_prefs', args => { blog_id => $blog_id },
    ));
}

1;