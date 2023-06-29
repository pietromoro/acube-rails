module ACube
  class SignatureChecker
    class InvalidSignatureError < StandardError; end

    HASH_ALGORIGHTM = "sha256"
    DEFAULT_KEY = "acube"
    DEFAULT_GPG = <<-GPG
      -----BEGIN PUBLIC KEY-----
      MCowBQYDK2VwAyEAvZlhiFh4aORWSC9hKZvZyKYgn2g2VeSguWoxu4fbqRI=
      -----END PUBLIC KEY-----
    GPG

    def self.verify_signature(request, payload)
      new(request.headers, payload).verify_signature
    end

    attr_reader :headers, :payload
    attr_accessor :signature, :input, :digest
    def initialize(headers, payload)
      @headers = headers
      if (!ACube.webhook_secret_key.nil? && !ACube.webhook_secret.nil?)
        raise InvalidSignatureError unless headers.has_key?("Authorization") && headers["Authorization"] == "#{ACube.webhook_secret_key} #{ACube.webhook_secret}"
      end

      raise InvalidSignatureError unless headers.has_key?("signature") && headers.has_key?("signature-input") && headers.has_key?("signature-digest")
      signature, input, digest = headers["signature"], headers["signature-input"], headers["signature-digest"]

      @payload = payload
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