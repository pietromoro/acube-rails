module ACube
  class SignatureChecker
    HASH_ALGORIGHTM = "sha256"
    DEFAULT_KEY = "acube"
    DEFAULT_GPG = <<-GPG
      -----BEGIN PUBLIC KEY-----
      MCowBQYDK2VwAyEAvZlhiFh4aORWSC9hKZvZyKYgn2g2VeSguWoxu4fbqRI=
      -----END PUBLIC KEY-----
    GPG

    def self.verify_signature(url, params)
      new(url, params).verify_signature
    end

    attr_reader :url, :params
    def initialize(url, params)
      @url = url
      @params = params
    end

    def verify_signature
      raw_data = url + params.sort.join
      OpenSSL::HMAC.digest(HASH_ALGORITHM, signature_gpg, raw_data)
    end

  private
    def signature_key
      ACube.webhook_signature_key || DEFAULT_KEY
    end

    def signature_gpg
      ACube.webhook_signature_gpg || DEFAULT_GPG
    end
  end
end