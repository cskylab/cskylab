<?php
$CONFIG = array (
  // Some Nextcloud options that might make sense here
  'allow_user_to_change_display_name' => false,
  'lost_password_link' => 'disabled',

  // URL of provider. All other URLs are auto-discovered from .well-known
  'oidc_login_provider_url' => 'https://keycloak.cskylab.net/auth/realms/cskylab',

  // Client ID and secret registered with the provider
  'oidc_login_client_id' => 'nextcloud',
  'oidc_login_client_secret' => 'ad7d0dcb-1450-4e80-8a74-9eb512e8a470',

  // Automatically redirect the login page to the provider
  'oidc_login_auto_redirect' => true,

  // Redirect to this page after logging out the user
  'oidc_login_logout_url' => 'https://keycloak.cskylab.net/auth/realms/cskylab/protocol/openid-connect/logout?redirect_uri=https%3A%2F%2Fcloud.example.com%2F',

  // Quota to assign if no quota is specified in the OIDC response (bytes)
  'oidc_login_default_quota' => '1000000000',

  // Login button text
  'oidc_login_button_text' => 'Log in with OpenID',

  // Hide the NextCloud password change form.
  'oidc_login_hide_password_form' => false,

  // Attribute map for OIDC response. Available keys are:
  //   i)   id:       Unique identifier for username
  //   ii)  name:     Full name
  //   iii) mail:     Email address
  //   iv)  quota:    Nextcloud storage quota
  //   v)   home:     Home directory location. A symlink or external storage to this location is used
  //   vi)  ldap_uid: LDAP uid to search for when running in proxy mode
  //   vii) groups:   Array or space separated string of NC groups for the user
  //
  // The attributes in the OIDC response are flattened by adding the nested
  // array key as the prefix and an underscore. Thus,
  //
  //     $profile = [
  //         'id' => 1234,
  //         'attributes' => [
  //             'uid' => 'myuid'
  //         ]
  //     ];
  //
  // would become,
  //
  //     $profile = [
  //         'id' => 1234,
  //         'attributes_uid' => 'myuid'
  //     ]
  //
  'oidc_login_attributes' => array (
      'id' => 'preferred_username',
      'mail' => 'email',
  ),

  // Default group to add users to (optional, defaults to nothing)
  'oidc_login_default_group' => 'oidc',

  // Use external storage instead of a symlink to the home directory
  // Requires the files_external app to be enabled
  'oidc_login_use_external_storage' => false,

  // Set OpenID Connect scope
  'oidc_login_scope' => 'openid profile',

  // Run in LDAP proxy mode
  // In this mode, instead of creating users of its own, OIDC login
  // will get the existing user from an LDAP database and only
  // perform authentication with OIDC. All user data will be derived
  // from the LDAP database instead of the OIDC user response
  //
  // The `id` attribute in `oidc_login_attributes` must return the
  // "Internal Username" (see expert settings in LDAP integration)
  'oidc_login_proxy_ldap' => false,

  // Disable creation of new users from OIDC login
  'oidc_login_disable_registration' => true,

  // Fallback to direct login if login from OIDC fails
  // Note that no error message will be displayed if enabled
  'oidc_login_redir_fallback' => true,

  // Use an alternative login page
  // This page will be php-included instead of a redirect if specified
  // In the example below, the PHP file `login.php` in `assets`
  // in nextcloud base directory will be included
  // Note: the PHP variable $OIDC_LOGIN_URL is available for redirect URI
  // Note: you may want to try setting `oidc_login_logout_url` to your
  // base URL if you face issues regarding re-login after logout
  'oidc_login_alt_login_page' => 'assets/login.php',
  
  // For development, you may disable TLS verification. Default value is `true`
  // which should be kept in production
  'oidc_login_tls_verify' => true,
);