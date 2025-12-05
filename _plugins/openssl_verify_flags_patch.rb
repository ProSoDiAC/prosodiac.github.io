# _plugins/openssl_verify_flags_patch.rb

require "openssl"

# 1. Make sure DEFAULT_PARAMS doesn't include :verify_flags,
#    since on your build SSLContext doesn't define verify_flags=
if OpenSSL::SSL::SSLContext.const_defined?(:DEFAULT_PARAMS)
  params = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS

  # Avoid calling a non-existent verify_flags=
  params.delete(:verify_flags)

  # 2. Add a verify_callback that *only* ignores the CRL retrieval error,
  #    and otherwise keeps normal verification.
  params[:verify_callback] = lambda do |preverify_ok, store_ctx|
    error = store_ctx.error

    # Ignore only: X509_V_ERR_UNABLE_TO_GET_CRL
    if error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
      true
    else
      preverify_ok
    end
  end
end

# 3. Define a no-op verify_flags= so that if anything tries to set it
#    at runtime, it doesn't crash.
class OpenSSL::SSL::SSLContext
  unless method_defined?(:verify_flags=)
    def verify_flags=(_flags)
      # no-op: ignore verify_flags on this build
    end
  end
end
