#!/usr/bin/env sh

# Add very basic support for adding TLSA records.

# Just pull in the code for calling the NederHost API like this. Not very
# clean.

. $(dirname $0)/dnsapi/dns_nederhost.sh

########  Public functions #####################

#domain keyfile certfile cafile fullchain
nederhost_tlsa_deploy() {
  _cdomain="$1"
  _ckey="$2"
  _ccert="$3"
  _cca="$4"
  _cfullchain="$5"

  _debug _cdomain "$_cdomain"
  _debug _ckey "$_ckey"
  _debug _ccert "$_ccert"
  _debug _cca "$_cca"
  _debug _cfullchain "$_cfullchain"

  NederHost_Key="${NederHost_Key:-$(_readaccountconf_mutable NederHost_Key)}"
  if [ -z "$NederHost_Key" ]; then
    NederHost_Key=""
    _err "You didn't specify a NederHost api key."
    _err "You can get yours from https://www.nederhost.nl/mijn_nederhost"
    return 1
  fi

  _debug "First detect the root zone"
  if ! _get_root "${_cdomain}"; then
    _err "invalid domain"
    return 1
  fi

  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  hash="$(${ACME_OPENSSL_BIN:-openssl} x509 -noout -pubkey -in ${_ccert} | ${ACME_OPENSSL_BIN:-openssl} rsa -pubin -outform DER 2>/dev/null | _digest "sha256" hex | tr "a-z" "A-Z")"
  
  _debug hash "$hash"

  _debug "Adding TLSA record"
  _nederhost_rest PATCH "zones/${_domain}/records/*.${_cdomain}/TLSA" "[{\"content\":\"3 1 1 ${hash}\",\"ttl\":60}]"

}
